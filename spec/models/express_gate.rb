require 'models/gate'

class ExpressGate < Gate
  
  attr_accessor :new_express_record

  state_machine do |sm|
    sm.initial_state "express_beginner"    
    sm.add_state "express_expert", :after_enter => :add_prize    
    sm.add_transition :make_express_beginner, :from => "expert", :to => "express_beginner"
    sm.add_transition :demote_express_beginner, :from => "express_beginner", :to => "expert"
    sm.add_transition :make_express_expert, :from => "express_beginner"
  end

  def add_prize
    self.prize_won ||= ""
    self.prize_won += "*"
  end

  def dummy_save
    @new_record = false
  end

  def new_record?
    @new_record
  end

  def initialize(initial_status = nil)
    @status = initial_status
    @new_record = true
    @prize_won = ""
    super
  end
end