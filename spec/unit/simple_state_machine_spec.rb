require 'spec_helper'
require 'ruby-debug'

describe SimpleStateMachine do
  describe "- Normal state machine" do
    before(:each) do
      @gate = Gate.new    
      @gate.should respond_to(:status)
    end

    describe "- Basic operations" do

      it "Should allow accessible methods to check if certain state is active on the including class" do
        @gate.methods.should include("beginner?")
        @gate.methods.should include("novice?")
        @gate.methods.should include("expert?")
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
        @gate.beginner?.should be_true
      end
    end

    describe "- Transitions" do

      it "should allow a gate to transition from 'beginner' to 'novice', normal method" do
        lambda {
            @gate.make_novice.should be_true
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.novice?.should be_true
      end

      it "should allow a gate to transition from 'beginner' to 'novice', with shebang" do
        lambda {
            @gate.make_novice!
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.novice?.should be_true
      end

      it "should not allow a gate to transition from 'beginner' to 'expert'" do
        lambda {
            @gate.make_expert.should be_false
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.beginner?.should be_true
      end

      it "should raise an exception if a gate tries to transition from 'beginner' to 'expert' with a shebang" do
        lambda {
            @gate.make_expert!
          }.should raise_error(SimpleStateMachine::Exceptions::InvalidTransition, "Could not transit 'beginner' to 'expert'")

        @gate.beginner?.should be_true
      end

      it "should allow a gate to transtition from 'expert' back to 'novice', normal method" do
        @gate.status = Gate.state_machine.states["expert"]
        lambda {
            @gate.make_novice.should be_true
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.novice?.should be_true
      end
      
      it "should allow a gate to transtition from 'expert' back to 'novice', with shebang" do
        @gate.status = Gate.state_machine.states["expert"]
        lambda {
            @gate.make_novice!
          }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

        @gate.novice?.should be_true
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
        @gate.novice?.should be_true
      end

      it "should not persist on a non-shebang persistency transition method" do
        @gate.new_record?.should be_true
        @gate.make_novice.should be_true
        @gate.new_record?.should be_true
        @gate.novice?.should be_true
      end
    end

    describe "- Events" do
      it "should add prizes to the gate when transitioning from 'beginner' to 'novice'" do
        @gate.prize_won.should be_empty
        @gate.make_novice.should be_true
        @gate.prize_won.should eql("*")
        @gate.novice?.should be_true
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
          ExpressGate::STATES["beginner"].should_not be_nil
          ExpressGate::STATES["novice"].should_not be_nil
          ExpressGate::STATES["expert"].should_not be_nil
          ExpressGate::STATES["express_beginner"].should_not be_nil
          ExpressGate::STATES["express_expert"].should_not be_nil
          ExpressGate::STATES["miki_level"].should_not be_nil
        end        
        
        it "Should allow accessible methods to check if certain state is active on the including class for parent class' states" do
          @gate.methods.should include("beginner?")
          @gate.methods.should include("novice?")
          @gate.methods.should include("expert?")
        end

        it "Should allow accessible methods to check if certain state is active on the including class for child class' states" do
          @gate.methods.should include("express_beginner?")
          @gate.methods.should include("express_expert?")
          @gate.methods.should include("miki_level?")
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
          @gate.express_beginner?.should be_true
        end
      end

      describe "- Transitions" do

        it "should allow a gate to transition from a state that comes from parent 'expert' to 'express_beginner', normal method" do
          lambda {
              @gate.status = ExpressGate.state_machine.states["expert"]
              @gate.make_express_beginner.should be_true
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.express_beginner?.should be_true
        end

        it "should allow a gate to transition from a state that comes from parent 'expert' to 'express_beginner', shebang method" do
          lambda {
              @gate.status = ExpressGate.state_machine.states["expert"]
              @gate.make_express_beginner!
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.express_beginner?.should be_true
        end

        it "should not allow a gate to transition from a state that comes from parent 'beginner' to 'express_beginner', normal method" do
          @gate.status = ExpressGate.state_machine.states["beginner"]
          lambda {
              @gate.make_express_beginner.should be_false
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.beginner?.should be_true
        end      

        it "should not allow a gate to transition from a state that comes from parent 'beginner' to 'express_beginner', shebang method" do
          @gate.status = ExpressGate.state_machine.states["beginner"]
          lambda {
              @gate.make_express_beginner!
            }.should raise_error(SimpleStateMachine::Exceptions::InvalidTransition, "Could not transit 'beginner' to 'express_beginner'")

          @gate.beginner?.should be_true
        end

        it "should allow a gate to transition from 'express_beginner' to 'express_expert', normal method" do
          lambda {
              @gate.make_express_expert.should be_true
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.express_expert?.should be_true
        end

        it "should allow a gate to transition from 'express_beginner' to 'express_expert', with shebang" do
          lambda {
              @gate.make_express_expert!
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.express_expert?.should be_true
        end

        it "should not allow a gate to transition from 'express_beginner' to 'miki_level'" do
          lambda {
              @gate.make_miki.should be_false
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.express_beginner?.should be_true
        end

        it "should raise an exception if a gate tries to transition from 'express_beginner' to 'miki_level' with a shebang" do
          lambda {
              @gate.make_miki!
            }.should raise_error(SimpleStateMachine::Exceptions::InvalidTransition, "Could not transit 'express_beginner' to 'miki_level'")

          @gate.express_beginner?.should be_true
        end

        it "should allow a gate to transition from a state that comes from child 'express_beginner' to 'expert', normal method" do
          @gate.status = ExpressGate.state_machine.states["express_beginner"]         
          lambda {
              @gate.demote_express_beginner.should be_true
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)  
          @gate.expert?.should be_true
        end

        it "should allow a gate to transition from a state that comes from child 'express_beginner' to state from parent 'expert', shebang method" do
          @gate.status = ExpressGate.state_machine.states["express_beginner"]   
          lambda {
              @gate.demote_express_beginner!
            }.should_not raise_error(SimpleStateMachine::Exceptions::InvalidTransition)

          @gate.expert?.should be_true
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
          @gate.express_expert?.should be_true
        end

        it "should not persist on a non-shebang transition method" do
          @gate.new_record?.should be_true
          @gate.make_express_expert
          @gate.new_record?.should be_true
          @gate.express_expert?.should be_true
        end
      end

      describe "- Events" do
        it "should add prizes to the gate when transitioning from 'beginner' to 'novice'" do
          @gate.prize_won.should be_empty
          @gate.make_express_expert
          @gate.prize_won.should eql("*")
          @gate.express_expert?.should be_true
        end
      end
    end    
  end
end