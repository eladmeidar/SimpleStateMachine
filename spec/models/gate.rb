class Gate
  include SimpleStateMachine

  attr_accessor :prize_won, :status, :new_record

  state_machine do |sm|
    sm.initial_state "beginner"
    sm.add_state "novice", :after_enter => :add_prize
    sm.add_state "expert", :after_enter => :add_prize
    sm.add_transition :make_novice, :from => "beginner", :to => "novice"
    sm.add_transition :make_expert, :from => "novice", :to => "expert"
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