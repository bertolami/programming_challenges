#/usr/bin/ruby

class NotABugAFeature
  attr_accessor :transitions
  attr_reader  :distance_to_goal
  def initialize n
    @transitions = Array.new
    @open_states = Array.new
    @visited_states = Hash.new
    initial_state = State.new("+" * n, 0)
    @open_states << initial_state
    @visited_states[initial_state.state_string] = initial_state
    @distance_to_goal = -1
    @goal_string = "-" * n
  end
 
  def run
    distance=0
     while @open_states.size > 0
      state = @open_states.shift
      @transitions.each do |transition|
        next_state = state.next_state transition
        if next_state and (@distance_to_goal == -1 or @distance_to_goal > next_state.distance)
          if not contains_closer_existing next_state
            @visited_states[next_state.state_string] = next_state
            @open_states << next_state
            if (@goal_string == next_state.state_string)
              if @distance_to_goal == -1 or @distance_to_goal > next_state.distance
                @distance_to_goal = next_state.distance  
              end
            end
          end        
        end
      end
    end
  end
  
  private 
  def contains_closer_existing state
      @visited_states[state.state_string] and @visited_states[state.state_string].distance < state.distance
  end
  
end

class Transition
  attr_reader :matcher, :applier

  def initialize(transitionString)
    (@matcher, @applier) = transitionString.split(/\s+/)
  end
end

class State
  attr_accessor :state_string, :distance
  
  def initialize state_string, distance
    @state_string = state_string
    @distance = distance
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
  
  private 
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
      applierBug == "0" ? stateBug : applierBug
   end
  
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
    if(engine.distance_to_goal >= 0) 
      puts "Shortest sequence takes #{engine.distance_to_goal} patches."
    else
      puts "Bugs cannot be fixed."
    end
    puts
    index += 1
  end
end



