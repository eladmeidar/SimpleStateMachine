class ExpressGate < Gate
  
  attr_accessor :new_express_record

  state_machine do |sm|
    sm.initial_state "express_beginner"    
    sm.add_state "express_expert", :after_enter => :add_prize
    sm.add_state "miki_level", :after_enter => :add_prize

    #sm.add_state "expert", :after_enter => :add_express_prize

    sm.add_transition :make_express_beginner, :from => "expert", :to => "express_beginner"
    sm.add_transition :demote_express_beginner, :from => "express_beginner", :to => "expert"
    sm.add_transition :make_express_expert, :from => "express_beginner", :to => "express_expert"
    sm.add_transition :make_miki, :from => "express_expert", :to => "miki_level"    
  end  

  def initialize(initial_status = nil)    
    super
  end
end