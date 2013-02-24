class SimplerStateMachine::Enum < Hash

  def initialize(*members)
    super()
    @rev = {}
    members.each_with_index {|m,i| self[i] = m }
  end

  def [](k)
     super || @rev[k]
  end

  def []=(k,v)
    @rev[v] = k
    super
  end
end

class StrictEnum < Hash

  module Exceptions
    class MemberNotFound < ArgumentError; end
  end

  def [](k)
     super || raise(Exceptions::MemberNotFound, "index/memeber '#{k}' not found in enum")
  end

end