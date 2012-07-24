require 'lib/simple_state_machine'

class Miki

  include SimpleStateMachine

  attr_accessor :status

  state_machine do |sm|
    sm.state_field :status
    sm.initial_state "gay"
    sm.add_state "out_of_closet", :before_enter => :tell_everyone
    sm.add_state "dating_other_men", :after_enter => :express_joy
    sm.add_transition :reveal, :from => "gay", :to => "out_of_closet"
    sm.add_transition :date, :from => ["out_of_closet", "gay"], :to => "dating_other_men"
  end

  def tell_everyone
    puts "Yay!"
  end

  def express_joy
    puts "Singing George Micheal!"
  end
end

class Adam < Miki

end

@miki = Adam.new
