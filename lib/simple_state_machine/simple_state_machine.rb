module SimpleStateMachine

  def self.included(base) #:nodoc:
    base.class_eval do
      extend ClassMethods
      include InstanceMethods

      alias :enum_state :enum_status
    end
  end

  module ClassMethods

    def state_machine(&block)
      return @sm if @sm
      @sm ||= SimpleStateMachine::Base.new(self)
      @sm.instance_eval(&block) if block_given?
      @sm.enumize!
      self.const_set(@sm.states_constant_name,@sm.states)
      return @sm
    end
  end

  module InstanceMethods

    def initialize(*args)      
      self.send("#{self.class.state_machine.state_field}=", self.class.state_machine.states[self.class.state_machine.initial_state].to_i)            

      begin
        super
      rescue ArgumentError
        super()
      end
    end

    def enum_status
      self.class.state_machine.states[self.current_state]
    end

    def current_state
      self.send(self.class.state_machine.state_field)
    end

    private

    def fire_state_machine_event(event)
      case event.class.name
      when "Proc"
        event.call
      when "Symbol", "String"
        self.send(event)
      when "Array"
        event.each do |e|
          fire_state_machine_event(e)
        end
      end
    end
  end
end
