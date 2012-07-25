module SimpleStateMachine
  class Base

    attr_reader :states, 
                :events, 
                :transitions, 
                :initial_state, 
                :state_field, 
                :persistency_method,
                :states_constant_name

    attr_accessor :clazz

    def initialize(clazz)      
      @clazz = clazz
      @_states = []
      @events = {}
      @transitions = {}
      @state_field = "status"
      @states_constant_name = "STATES"
      @persistency_method = nil
    end

    def initialize_copy(orig)
      puts 'initialize copy'
      super
      @states = orig.states.clone
      @_states = orig.instance_variable_get("@_states").clone
      @events = orig.events.clone
      @transitions = orig.transitions.clone
      @initial_state = orig.initial_state.clone
      @state_field = orig.state_field
      @persistency_method = orig.persistency_method.clone unless @persistency_method.nil?
      @states_constant_name = orig.states_constant_name.clone      
    end

    def states_constant_name(constant_name = nil)
      if constant_name.nil?
        @states_constant_name
      else
        @states_constant_name = constant_name.upcase
      end
    end

    def persistency_method(method_name = nil)
      if method_name.nil?
        @persistency_method
      else
        @persistency_method = method_name
      end
    end

    def state_field(state_field = nil)
      if state_field.nil?
        @state_field
      else
        @state_field = state_field
      end
    end

    def initial_state(initial_state = nil)
      if initial_state.nil?
        @initial_state
      else
        add_state(initial_state)
        @initial_state = initial_state
      end
    end

    def add_state(state_name, options = {})
      options =  { :before_enter => Proc.new { true },
                    :after_enter => Proc.new { true },
                    :before_leave => Proc.new { true },
                    :after_leave => Proc.new { true },
                    :on_error => Proc.new { |error| true } }.merge(options)

      @_states << human_state_name(state_name)
      @events[human_state_name(state_name)] = options.dup

      @clazz.instance_eval do
        define_method("#{state_name}?") do
          self.send(self.class.state_machine.state_field) == state_name.to_s
        end
      end
    end

    def add_transition(transition_name, options = {})

      options[:from] = options[:from].is_a?(Array) ? options[:from] : options[:from].to_a

      @transitions[transition_name.to_s] = options
      @clazz.instance_eval do
        define_method("#{transition_name}") do
          if self.class.state_machine.transitions[transition_name.to_s] && self.class.state_machine.transitions[transition_name.to_s][:from].include?(self.enum_status.to_sym.to_s)
            
            current_state_events = self.class.state_machine.events[self.enum_status.to_sym.to_s]
            next_state_events = self.class.state_machine.events[self.class.state_machine.transitions[transition_name.to_s][:to]]

            begin
              fire_state_machine_event(current_state_events[:before_leave])
              fire_state_machine_event(next_state_events[:before_enter])
              self.send("#{self.class.state_machine.state_field}=", self.class.state_machine.states[self.class.state_machine.transitions[transition_name.to_s][:to]].to_i)
              self.send(self.class.state_machine.persistency_method) if self.class.state_machine.persistent_mode?
              fire_state_machine_event(current_state_events[:after_leave])
              fire_state_machine_event(next_state_events[:after_enter])
            rescue Exception => e
              fire_state_machine_event(current_state_events[:on_error])
            end
            return true
          else
            return false
          end
        end

        define_method("#{transition_name}!") do
          if !(self.send(transition_name))
            raise Exceptions::InvalidTransition, "Could not transit '#{self.enum_status.to_sym.to_s}' to '#{options[:to]}'"
          else
            return true
          end
        end        
      end
    end

    def enumize!      
      @states = Enum.new(*@_states)
    end

    def persistent_mode?
      !(@persistency_method.nil?)
    end

    protected

    private 

    def human_state_name(state)
      state.to_s.downcase
    end
  end
end