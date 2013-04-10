require "chalk_dust/version"

module ChalkDust
  class Connection < ActiveRecord::Base
    belongs_to :publisher,  :polymorphic => true
    belongs_to :subscriber, :polymorphic => true

    def self.subscribers_of(publisher)
      where(:publisher_id => publisher.id,
            :publisher_type => publisher.class.to_s).map(&:subscriber)
    end
  end

  class ActivityItem < ActiveRecord::Base
    belongs_to :performer, :polymorphic => true
    belongs_to :target,    :polymorphic => true
    belongs_to :owner,     :polymorphic => true

    validates :event, :presence => true

    def self.for_owner(owner)
      where(:owner_id => owner.id,
            :owner_type => owner.class.to_s)
    end

    def self.since(time)
      where("created_at >= ?", time)
    end
  end

  def self.subscribe(subscriber, options)
    publisher  = options.fetch(:to)
    undirected = options.fetch(:undirected, false)
    Connection.create(:subscriber => subscriber, :publisher => publisher)
    Connection.create(:subscriber => publisher,  :publisher => subscriber) if undirected
  end

  def self.subscribers_of(publisher)
    Connection.subscribers_of(publisher)
  end

  def self.self_subscribe(publisher_subscriber)
    subscribe(publisher_subscriber, :to => publisher_subscriber)
  end

  # publishes an event where X (performer) did Y (event) to Z (target) to every
  # subscriber of the target
  def self.publish_event(performer, event, target, options = {})
    root_publisher = options.fetch(:root, target)
    subscribers_of(root_publisher).map do |subscriber|
      ActivityItem.create(:performer => performer,
                          :event     => event,
                          :target    => target,
                          :owner     => subscriber)
    end
  end

  def self.activity_feed_for(subscriber, options = {})
    activity_items = ActivityItem.for_owner(subscriber)
    activity_items = activity_items.since(options[:since]) if options[:since].present?
    activity_items
  end
end
