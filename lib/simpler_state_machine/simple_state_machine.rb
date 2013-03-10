=begin
SimpleStateMachine
==================

This module should be mixed in to a class that needs a state machine implementation. refer to the readme.
=end
module SimplerStateMachine

  def self.included(base) #:nodoc:
    base.class_eval do
      extend ClassMethods
      include InstanceMethods

      # Alias the enum reference method for the confused end user.
      alias :enum_state :enum_status

    end
  end

  module ClassMethods

    # When inherited - duplicate the state machine from the parent class and allow the extend it
    def inherited(child)
      me = self
      child.class_eval do
        @sm = me.state_machine.clone
        @sm.clazz = self
      end
    end

    # Create or return a state machine
    def state_machine(&block)
      return @sm if !(@sm.nil?) && !(block_given?)
      @sm ||= SimplerStateMachine::Base.new(self)
      @sm.instance_eval(&block) if block_given?
      @sm.enumize!
      self.const_set(@sm.states_constant_name,@sm.states).freeze
      return @sm
    end
  end

  module InstanceMethods

    # Set the initial status value
    def initialize(*args)      
      self.send("#{self.class.state_machine.state_field}=", self.class.state_machine.states[self.class.state_machine.initial_state].to_i)            

      begin
        super
      rescue ArgumentError # Catch in case the super does not get parameters
        super()
      end
    end

    # Return the enum status
    def enum_status
      self.class.state_machine.states[self.current_state]
    end

    # Return the current state
    def current_state
      self.send(self.class.state_machine.state_field)
    end

    # human name for status
    def human_status_name
      enum_status
    end

    private

    # Fire a callback, support a symbol, string or an array of symbols / strings
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
