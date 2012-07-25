# SimpleStateMachine

SimpleStateMachine is a simple (suprisingly) state machine aimed to provide a simpler implementation and setup for ruby based state machines.

## Installation

Add this line to your application's Gemfile:

    gem 'simple_state_machine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_state_machine

## Usage

SimpleStateMachine provides an easy interface to add states and transitions:

```ruby
Class Elad
  state_machine do |sm|
    sm.initial_state "happy"
    sm.state_field "status"
    sm.add_state "mad", :before_enter => :kill_miki, 
                        :after_enter => :kiss_miki, 
                        :before_leave => :kick_miki, 
                        :after_leave => :keep_miki
    sm.add_transition :get_angry, :from => "happy", :to => "mad"
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
