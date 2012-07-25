class KingGate < Gate

  state_machine do |sm|
    sm.initial_state "king_beginner"
    sm.add_state "king_novice", :after_enter => :add_prize
    sm.add_state "king_expert", :after_enter => :add_prize
    sm.add_transition :make_king_novice, :from => "king_beginner", :to => "king_novice"
    sm.add_transition :make_king_expert, :from => "king_novice", :to => "king_expert"
  end  

  def initialize(initial_status = nil)        
    super
  end
end