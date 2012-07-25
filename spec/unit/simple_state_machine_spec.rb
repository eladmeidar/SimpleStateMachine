require 'spec_helper'
require 'ruby-debug'

describe SimpleStateMachine do
  describe "- Normal state machine" do
    before(:each) do
      @gate = Gate.new    
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
            @gate.make_novice.should be_true
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.enum_state.should eql(Gate::STATES::NOVICE)
      end

      it "should allow a gate to transition from 'beginner' to 'novice', with shebang" do
        lambda {
            @gate.make_novice!
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

      it "should allow a gate to transtition from 'expert' back to 'novice', normal method" do
        @gate.status = Gate::STATES::EXPERT.index
        lambda {
            @gate.make_novice.should be_true
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.enum_state.should eql(Gate::STATES::NOVICE)
      end
      
      it "should allow a gate to transtition from 'expert' back to 'novice', with shebang" do
        @gate.status = Gate::STATES::EXPERT.index
        lambda {
            @gate.make_novice!
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.enum_state.should eql(Gate::STATES::NOVICE)
      end

    end

    describe "- Persistency" do
      before(:all) do
        Gate.state_machine.persistency_method(:dummy_save)
      end

      it "should persist on a shebang persistency transition method" do
        @gate.new_record?.should be_true
        @gate.make_novice!
        @gate.new_record?.should be_false
        @gate.enum_state.should eql(Gate::STATES::NOVICE)
      end

      it "should not persist on a non-shebang persistency transition method" do
        @gate.new_record?.should be_true
        @gate.make_novice.should be_true
        @gate.new_record?.should be_true
        @gate.enum_state.should eql(Gate::STATES::NOVICE)
      end
    end

    describe "- Events" do
      it "should add prizes to the gate when transitioning from 'beginner' to 'novice'" do
        @gate.prize_won.should be_empty
        @gate.make_novice.should be_true
        @gate.prize_won.should eql("*")
        @gate.enum_state.should eql(Gate::STATES::NOVICE)
      end
    end
  end

  describe "- Inheritence" do
    describe "- parent class state machine" do
      before(:each) do
        #create both KingGate & ExpressGate to fail class level attributes integrity        
        @kinggate = KingGate.new        
        @gate = ExpressGate.new    
        @gate.should respond_to(:status)        
      end

      describe "- Basic operations" do
        it "Should allow accessible constants on the including class" do
          ExpressGate.constants.should include("STATES")
          ExpressGate::STATES.all.should include(ExpressGate::STATES::BEGINNER)
          ExpressGate::STATES.all.should include(ExpressGate::STATES::NOVICE)
          ExpressGate::STATES.all.should include(ExpressGate::STATES::EXPERT)
          ExpressGate::STATES.all.should include(ExpressGate::STATES::EXPRESS_BEGINNER)
          ExpressGate::STATES.all.should include(ExpressGate::STATES::EXPRESS_EXPERT)
          ExpressGate::STATES.all.should include(ExpressGate::STATES::MIKI_LEVEL)
        end        

        it "should have a state_machine reference" do
          @gate.class.should respond_to(:state_machine)
        end

        it "should respond to the default state field" do
          @gate.should respond_to(ExpressGate.state_machine.state_field)
        end

        it "should set the default state field to 'status'" do
          ExpressGate.state_machine.state_field.should eql("status")
        end

        it "should set an initial status" do          
          @gate.status.should eql(ExpressGate.state_machine.states["express_beginner"].to_i)
        end

        it "should force an initial status even if one specified by a default class constructor" do          
          @gate = ExpressGate.new("bogus_status")
          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_BEGINNER)
        end
      end

      describe "- Transitions" do

        it "should allow a gate to transition from a state that comes from parent 'expert' to 'express_beginner', normal method" do
          lambda {
              @gate.status = ExpressGate::STATES::EXPERT.index
              @gate.make_express_beginner.should be_true
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_BEGINNER)
        end

        it "should allow a gate to transition from a state that comes from parent 'expert' to 'express_beginner', shebang method" do
          lambda {
              @gate.status = ExpressGate::STATES::EXPERT.index
              @gate.make_express_beginner!
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_BEGINNER)
        end

        it "should not allow a gate to transition from a state that comes from parent 'beginner' to 'express_beginner', normal method" do
          @gate.status = ExpressGate::STATES::BEGINNER.index
          lambda {
              @gate.make_express_beginner.should be_false
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::BEGINNER)
        end      

        it "should not allow a gate to transition from a state that comes from parent 'beginner' to 'express_beginner', shebang method" do
          @gate.status = ExpressGate::STATES::BEGINNER.index
          lambda {
              @gate.make_express_beginner!
            }.should raise_error(SimpleStateMachine::Exceptions::InvalidTransition, "Could not transit 'beginner' to 'express_beginner'")

          @gate.enum_state.should eql(ExpressGate::STATES::BEGINNER)
        end

        it "should allow a gate to transition from 'express_beginner' to 'express_expert', normal method" do
          lambda {
              @gate.make_express_expert.should be_true
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_EXPERT)
        end

        it "should allow a gate to transition from 'express_beginner' to 'express_expert', with shebang" do
          lambda {
              @gate.make_express_expert!
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_EXPERT)
        end

        it "should not allow a gate to transition from 'express_beginner' to 'miki_level'" do
          lambda {
              @gate.make_miki.should be_false
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_BEGINNER)
        end

        it "should raise an exception if a gate tries to transition from 'express_beginner' to 'miki_level' with a shebang" do
          lambda {
              @gate.make_miki!
            }.should raise_error(SimpleStateMachine::Exceptions::InvalidTransition, "Could not transit 'express_beginner' to 'miki_level'")

          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_BEGINNER)
        end

        it "should allow a gate to transition from a state that comes from child 'express_beginner' to 'expert', normal method" do
          @gate.status = ExpressGate::STATES::EXPRESS_BEGINNER.to_i         
          lambda {
              @gate.demote_express_beginner.should be_true
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)  
          @gate.enum_state.should eql(ExpressGate::STATES::EXPERT)
        end

        it "should allow a gate to transition from a state that comes from child 'express_beginner' to state from parent 'expert', shebang method" do
          @gate.status = ExpressGate::STATES::EXPRESS_BEGINNER.to_i          
          lambda {
              @gate.demote_express_beginner!
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.enum_state.should eql(ExpressGate::STATES::EXPERT)
        end
      end

      describe "- Persistency" do
        before(:all) do
          ExpressGate.state_machine.persistency_method(:dummy_save)
        end

        it "should persist on a shebang transition method" do
          @gate.new_record?.should be_true
          @gate.make_express_expert!
          @gate.new_record?.should be_false
          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_EXPERT)
        end

        it "should not persist on a non-shebang transition method" do
          @gate.new_record?.should be_true
          @gate.make_express_expert
          @gate.new_record?.should be_true
          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_EXPERT)
        end
      end

      describe "- Events" do
        it "should add prizes to the gate when transitioning from 'beginner' to 'novice'" do
          @gate.prize_won.should be_empty
          @gate.make_express_expert
          @gate.prize_won.should eql("*")
          @gate.enum_state.should eql(ExpressGate::STATES::EXPRESS_EXPERT)
        end
      end
    end    
  end
end