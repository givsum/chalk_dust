module ChalkDust
  class ActivityItem < ActiveRecord::Base
    belongs_to :performer, :polymorphic => true
    belongs_to :target,    :polymorphic => true
    belongs_to :owner,     :polymorphic => true

    validates :event, :presence => true
    
    def self.event( event )
      where("event IN (?)", event)
    end
    
    def self.for_owner(owner)
      where(
        :owner_id   => owner.id,
        :owner_type => owner.class.to_s
      )
    end
    
    def self.limit( n )
      limit(n)
    end
    
    def self.order( order_by )
      order(order_by)
    end
    
    def self.performer( subscriber, performer )
      if 'self' == performer
        where(
          performer_id: subscriber.id,
          performer_type: subscriber.class.to_s
        )
      else
        where("(performer_id = ? AND performer_type = ?) IS NOT TRUE", subscriber.id, subscriber.class.to_s)
      end
    end
    
    def self.since(time)
      where("created_at >= ?", time)
    end
    
    def self.target_type( target_type )
      where("target_type IN (?)", target_type)
    end
    
    def self.with_topic(topic)
      where(topic: topic)
    end
    
  end
end
