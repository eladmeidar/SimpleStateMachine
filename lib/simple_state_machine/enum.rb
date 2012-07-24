# Enum
# ----
#
# Created: Elad meidar 3/7/2012
#
# Usage:
# Color = Enum.new(:Red, :Green, :Blue)
# Color.is_a?(Enum) # => true
# Color::Red.inspect # => "Color::Red"
# Color::Green.is_a?(Color) # => true
# Color::Green.is_a?(Enum::Member) # => true
# Color::Green.index # => 1
# Color::Blue.enum # => Color
# values = [[255, 0, 0], [0, 255, 0], [0, 0, 255]]
# values[Color::Green] # => [0, 255, 0]
# Color[0] # => Color::Red
# Color.size # => 3
#
# Enums are enumerable. Enum::Members are comparable.

class Enum < Module 

  def initialize(*symbols, &block)
    @members = []
    symbols.each_with_index do |symbol, index|
      # Allow Enum.new(:foo)
      symbol = symbol.to_s.upcase
      member = Enum::Member.new(self, index, symbol)
      const_set(symbol, member)
      @members << member 
    end 
    super(&block) 
  end 

  def all
    @members
  end

  def [](val)
    if val.is_a?(Numeric) 
      @members[val]
    elsif val.is_a?(Symbol) || val.is_a?(String)
      found = @members.select {|member| member.name == val.to_s}
      if found.size > 0
        found.first
      end
    end
  end 

  def size 
    @members.size 
  end 
  
  alias :length :size 
  
  def first(*args) 
    @members.first(*args) 
  end 
  
  def last(*args) 
    @members.last(*args) 
  end 
  
  def each(&block) 
    @members.each(&block) 
  end 
  
  include Enumerable 
end

class Enum::Member < Module 
    attr_reader :enum, :index, :name

    def initialize(enum, index, name) 
      @enum, @index, @name = enum, index , name
      @name = name.to_s.downcase
      # Allow Color::Red.is_a?(Color) 
      extend enum 
    end 
    
    # Allow use of enum members as array indices 
    alias :to_int :index 
    alias :to_i :index 

    def to_s
      @name.upcase
    end

    def to_sym
      @name.to_sym
    end

    def name
      @name
    end

    # Allow comparison by index 
    def <=>(other)
      @index <=> other.index
    end

    include Comparable
end