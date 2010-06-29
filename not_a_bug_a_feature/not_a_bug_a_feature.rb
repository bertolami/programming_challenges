#/usr/bin/ruby

class NotABugAFeature
  attr_accessor :transitions
  attr_reader  :distance_to_goal
  def initialize n
    @transitions = Array.new
    @open_states = Array.new
    @closed_states = Hash.new
    @open_states << State.new("-" * n, 0)
    @distance_to_goal = -1
    @goal_string = "+" * n
  end
 
  def run
    log @open_states
    while @open_states.size > 0
      state = @open_states.shift
      if not contains_closer_existing state
        @closed_states[state.state_string] = state
      end
      log state
      @transitions.each do |transition|
        next_state = state.next_state transition
        if next_state
          if (@goal_string == next_state.state_string)
            if @distance_to_goal == -1 or @distance_to_goal > next_state.distance
              @distance_to_goal = next_state.distance  
            end
          else
            if not contains_closer_existing next_state
              @open_states << next_state
            end
          end
        end
      end
    end
  end
  def contains_closer_existing state
      existing = @closed_states[state.state_string]
      existing and existing.distance < state.distance
  end
  
  def goal? state_string
    @goal_string == state_string
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
  attr_accessor :state_string, :distance
  def initialize state_string, distance
    @state_string = state_string
    @distance = distance
  end
  
  def applies? transition
    0.upto(@state_string.length-1) do |i|
      return false if(not matching_bug(@state_string[i..i], transition.matcher[i..i]))    
    end
    true
  end
  
  def matching_bug(stateBug, matcherBug)
    stateBug == matcherBug or matcherBug == "0"
  end
  
  def bug(stateBug, applierBug)
     if applierBug == "0"
       stateBug
     else 
       applierBug
     end
  end
  
  def next_state transition
    if(applies? transition) 
      state_string = ""
      0.upto(@state_string.length-1) do |i|
        state_string << bug(@state_string[i..i], transition.applier[i..i])    
      end
      State.new(state_string, @distance +1)
    else
      nil
    end
  end
  def to_s
    "#{@state_string} (#{@distance})"
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
    (n, m) = input[index].split(/\s+/).map{|x| x.to_i}
    engine = NotABugAFeature.new n
    caze += 1
    1.upto(m) do |i|
      index += 1
      engine.transitions << Transition.new(input[index])
    end
    
    puts "Product #{caze}"
    engine.run
    puts "minimal distance #{engine.distance_to_goal}"
    index += 1
  end
end



