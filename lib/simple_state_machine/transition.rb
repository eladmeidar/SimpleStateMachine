module SimpleStateMachine
  class Transition

    attr_accessor :to, :from

    def initialize(options = {})
      options.assert_valid_keys :from, :to
      @to = options[:to]
      @from = options[:from]
    end
  end
end