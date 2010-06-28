#/usr/bin/ruby

class NotABugAFeature
  attr_accessor :transitions
  def initialize 
    @transitions = Array.new
    
  end
 
  
end

class Transition
  attr_reader :matcher, :applier
  def initialize(transitionString)
    (@matcher, @applier) = transitionString.split(/\s+/)
  end
  
  def to_s
    "#{@matcher} -> #{@applier}"
  end
end

class State
  def initialize stateString
    @stateString = stateString
  end
  
  def applies? transition
    0.upto(@stateString.length-1) do |i|
      return false if(not matchingBug(@stateString[i..i], transition.matcher[i..i]))    
    end
    true
  end
  
  def matchingBug(stateBug, matcherBug)
    stateBug == matcherBug or matcherBug == "0"
  end
  
  def bug(stateBug, applierBug)
     if applierBug == "0"
       stateBug
     else 
       applierBug
     end
  end
  
  def nextState transition
    if(applies? transition) 
      stateString = ""
      0.upto(@stateString.length-1) do |i|
        stateString << bug(@stateString[i..i], transition.applier[i..i])    
      end
    else
      nil
    end
  end
end

def log string
  puts "- #{string}"
end

input = []
while gets
   input << $_.chomp 
end

index = 0
caze = 0
while true
  exit if input[index] =~ /^0 0$/ 
  if input[index] =~ /^\d+\s+\d+$/  
    engine = NotABugAFeature.new
    (n, m) = input[index].split(/\s+/).map{|x| x.to_i}
    caze += 1
    1.upto(m) do |i|
      index += 1
      engine.transitions << Transition.new(input[index])
      log input[index]
    end
    puts "Product #{caze}"
    puts "Hallo (#{n} #{m}) #{engine.transitions.join ' '}"
    index += 1
  end
end



