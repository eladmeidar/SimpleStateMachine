# Note:

This code used to contain some offensive wording as part of our test suite that was not removed or at least moderated while
moving this project from private to public status. the people that worked on this project and myself especially are sincerely sorry and we absolutely 100% didn't mean
to offend anyone. sorry. :(

# SimpleStateMachine

__SimpleStateMachine__ is a simple (suprisingly) state machine aimed to provide a simpler implementation and setup for ruby based state machines.
It supports:

* States as enum
* Events / Callbacks
* Transitions

## Installation

Add this line to your application's Gemfile:

    gem 'simple_state_machine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_state_machine

## Usage

__SimpleStateMachine__ provides an easy interface to add states and transitions:


### Declaration

    Class Elad

      include SimpleStateMachine

      state_machine do |sm|
        sm.initial_state "happy"
        sm.state_field "status"
        sm.add_state "mad", :before_enter => :kill_miki, 
                            :after_enter => :kiss_miki, 
                            :before_leave => :kick_miki, 
                            :after_leave => :keep_miki,
                            :on_error => :tell_mom
        sm.add_state 'calm', :after_enter => :kiss_miki
        sm.add_transition :get_angry, :from => "happy", :to => "mad"
        sm.add_transition :calmate, :from => ["happy", "mad"], :to => "calm"
      end
    end

### Configuration Options

* `initial_state`: Sets up the initial state the class will get when instantiating a new instance.
* `state_field`: the field / attribute that keeps the status enum (defaults to "status")
* `add_state`: adding a state, accepts a state name and a list of callbacks.
* `add_transition`: defines a transtions with destination state and source state (or multiple in an array)
* `persistency_method`: __SimpleStateMachine__ doesn't rely on the existance of a persistency layer (ActiveRecord for example), so if you want to have this option you'll need to specify the persistency method to use (in ActiveRecord's case, use "save" or "save!")

### Enum States

__SimpleStateMachine__ uses Enum constants to represent states to allow better database integration (integers instead of strings to represent states).
In the example above you'll be able to use:

    Elad::STATES::Happy # => Happy
    Elad::STATES::Mad   # => Mad
    Elad::STATES::Calm  # => Calm
    Elad::STATES.all    # => [Happy, Mad, Calm]

also, the enum representation is available on any of the constants

    Elad::STATES::Happy.to_i # => 0

### Accessing States

__SimpleStateMachine__ will save the state's enum value as integer to the defined attribute, in order to access the string / constant representation of the state use `#enum_state`:

    > elad = Elad.new
    > elad.status
    0
    > elad.enum_state
    Happy

### Callbacks / Events

__SimpleStateMachine__ makes several callbacks available when defining a state and will fire them when a state transtion is made.
The available callbacks are:

* `:before_enter`: runs before the state is entered.
* `:after_enter`: runs after the state transition is completed
* `:before_leave`: runs before a transition to another state starts
* `:after_leave`: runs after a transition to another state runs
* `:on_error`: runs when the transition fails

The order in which the callbacks are called is:

    before_leave (of the current state)
    before_enter (of the destination state)
    <transition>
    after_leave (of the current state)
    after_enter (of the destination state)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
