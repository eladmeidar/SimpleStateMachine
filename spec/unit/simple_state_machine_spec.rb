require 'spec_helper'

describe SimpleStateMachine do
  before(:each) do
    @gate = Gate.new
    @express_gate = ExpressGate.new
    @gate.should respond_to(:status)
  end

  describe "- Basic operations" do
    it "Should allow accessible constants on the including class" do
      Gate.constants.should include("STATES")
      Gate::STATES.all.should include(Gate::STATES::BEGINNER)
      Gate::STATES.all.should include(Gate::STATES::NOVICE)
      Gate::STATES.all.should include(Gate::STATES::EXPERT)
    end

    it "should have a state_machine reference" do
      @gate.class.should respond_to(:state_machine)
    end

    it "should respond to the default state field" do
      @gate.should respond_to(Gate.state_machine.state_field)
    end

    it "should set the default state field to 'status'" do
      Gate.state_machine.state_field.should eql("status")
    end

    it "should set an initial status" do
      @gate.status.should eql(Gate.state_machine.states["beginner"].to_i)
    end

    it "should force an initial status even if one specified by a default class constructor" do
      @gate = Gate.new("bogus_status")
      @gate.enum_state.should eql(Gate::STATES::BEGINNER)
    end
  end

  describe "- Transitions" do

    it "should allow a gate to transition from 'beginner' to 'novice', normal method" do
      lambda {
          @gate.make_novice
        }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

      @gate.enum_state.should eql(Gate::STATES::NOVICE)
    end

    it "should not allow a gate to transition from 'beginner' to 'expert'" do
      lambda {
          @gate.make_expert.should be_false
        }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

      @gate.enum_state.should eql(Gate::STATES::BEGINNER)
    end

    it "should raise an exception if a gate tries to transition from 'beginner' to 'expert' with a shebang" do
      lambda {
          @gate.make_expert!
        }.should raise_error(SimpleStateMachine::Exceptions::InvalidTransition, "Could not transit 'beginner' to 'expert'")

      @gate.enum_state.should eql(Gate::STATES::BEGINNER)
    end
  end

  describe "- Persistency" do
    before(:all) do
      Gate.state_machine.persistency_method(:dummy_save)
    end

    it "should call the persistency method when found" do
      @gate.new_record?.should be_true
      @gate.make_novice
      @gate.new_record?.should be_false
      @gate.enum_state.should eql(Gate::STATES::NOVICE)
    end
  end

  describe "- Events" do
    it "should add prizes to the gate when transitioning from 'beginner' to 'novice'" do
      @gate.prize_won.should be_empty
      @gate.make_novice
      @gate.prize_won.should eql("*")
      @gate.enum_state.should eql(Gate::STATES::NOVICE)
    end
  end
end