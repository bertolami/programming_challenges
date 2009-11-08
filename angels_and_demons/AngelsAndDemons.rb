#/usr/bin/ruby

def log s
  #puts s.to_s
end
class AngelsAndDemons
  attr_reader :inhabitants
  
  def initialize
    @inhabitants = []
  end

  def self.inhabitant_types
    [:angel, :demon, :human]
  end

  def self.daytime_types
    [:day, :night]
  end
  
  def expression_from_string string
    (speaker, rest) = string.split ':'
    speaker = speaker.strip
    @inhabitants << speaker.to_sym
    rest = rest.strip
    negate = rest.include? "not"
    rest = rest.gsub /\s+not\s+/, ' ' if negate
    if rest.include? "is a"
      (subject, type) = rest.split " is a "
      @inhabitants << subject.to_sym
      SubjectTypeExpression.new speaker, subject, type, negate
    elsif rest.include? "I am a"
      type = rest.split(" ").pop
      SubjectTypeExpression.new speaker, speaker, type, negate
    elsif rest.include? "I am lying"
      SubjectLyingExpression.new speaker, speaker, negate
    elsif rest.include? "is lying"
      subject = rest.split(" ").shift.strip
      @inhabitants << subject.to_sym
      SubjectLyingExpression.new speaker, subject, negate
    elsif rest.include? "It is"
      daytime = rest.split(" ").pop.strip
      DayTimeExpression.new speaker, daytime
    else
      puts "NOT ABLE TO PARSE #{rest}"
    end
  end
end

class Configuration
  attr_reader :daytime, :inhabitant_types
  def initialize inhabitant_types, daytime
    @inhabitant_types = inhabitant_types
    @daytime = daytime
  end

  def inhabitants
    @inhabitant_types.keys
  end

  def inhabitant_type inhabitant
    @inhabitant_types[inhabitant]
  end

  def eql? other
   @daytime == other.daytime and @inhabitant_types == other.inhabitant_types
  end
  def hash
    @daytime.hash
  end

  def to_s
    s = "|"
    @inhabitant_types.keys.each do |key|
      s  += (" #{key} => "+ @inhabitant_types[key].to_s)
    end
    s += " (#{daytime}) |"
  end
end

class Expression
  attr_reader :satifying_configurations
  def initialize
    @satifying_configurations = []
  end

  def deduct inhabitants
    if @satifying_configurations.size == 0
      return  "This is impossible"
    end
    facts = []
    inhabitants.each do |inhabitant|
      inhabitant_types = []
      @satifying_configurations.each do |c|
        inhabitant_types << c.inhabitant_type(inhabitant)
      end
      facts << "#{inhabitant} is a #{inhabitant_types.uniq}" if inhabitant_types.uniq.size == 1
    end
    daytimes = []
    @satifying_configurations.each do |c|
      daytimes << c.daytime
    end
    facts << "It is a #{daytimes.pop}" if daytimes.uniq.size == 1
    if facts.size == 0
      "No facts are deducible"
    else
      facts.uniq.join "\n"
    end
      
   end
end

class CompositeExpression < Expression
  def initialize expression_one, expression_two
    super()
    @expression_one = expression_one
    @expression_two = expression_two
    calculate_satifying_configurations
  end
  
  def calculate_satifying_configurations
    log "\ncomposing two expressions #{@expression_one} and #{@expression_two}"
    tmp = []
     @expression_one.satifying_configurations.each do |c1|
        @expression_two.satifying_configurations.each do |c2|
          tmp << "#{compose(c1, c2)}" if satisfied?(c1, c2)
          @satifying_configurations << compose(c1, c2) if satisfied?(c1, c2)
        end
     end
     tmp = tmp.uniq
     size = tmp.size
     tmp = tmp.join("\n")
     log "matching compositions \n#{tmp}"
     @satifying_configurations = @satifying_configurations.uniq
     raise "uniq failed expected: \n#{size} \n but was #{@satifying_configurations.size} #{@satifying_configurations}\n" unless @satifying_configurations.size == size
  end
  
  def compose c1, c2
    inhabitants_map = {}
    (c1.inhabitants + c2.inhabitants).uniq.each do |inhabitant|
      type = c1.inhabitant_type inhabitant
      type ||= c2.inhabitant_type inhabitant
      inhabitants_map[inhabitant] = type
    end 
    Configuration.new inhabitants_map, c1.daytime
  end
  
  def satisfied? c1, c2
    return false unless c1.daytime == c2.daytime
    (c1.inhabitants + c2.inhabitants).each do |inhabitant|
      if c1.inhabitant_type(inhabitant) && c2.inhabitant_type(inhabitant) && c1.inhabitant_type(inhabitant) != c2.inhabitant_type(inhabitant)
        return false
      end
    end
    true
  end
  
  def to_s
    "#{@expression_one} AND #{@expression_two}"
  end
end

class SpeakerExpression < Expression
  attr_accessor :speaker, :speaker_type

  def initialize speaker
    super()
    @speaker = speaker.to_sym
  end
  
 
end

class SubjectExpression < SpeakerExpression
  attr_reader :subject, :negate
  def initialize speaker, subject, negate
    super speaker
    @negate = negate
    @subject = subject.to_sym
  end
  
  def initial_configurations 
    configurations = []
    AngelsAndDemons.inhabitant_types.each do |speaker_type| 
          if(@speaker == @subject) 
            configurations << Configuration.new({@speaker => speaker_type}, :day)
            configurations << Configuration.new({@speaker => speaker_type}, :night)
          else
            AngelsAndDemons.inhabitant_types.each do |subject_type|  
              configurations << Configuration.new({@speaker => speaker_type, @subject => subject_type},:day)
              configurations << Configuration.new({@speaker => speaker_type, @subject => subject_type},:night)
            end  
          end
    end
    configurations.uniq
  end
  
  def calculate_satifying_configurations
     log "\ncalculating a subject expression #{to_s}"
     tmp = []
    initial_configurations.each do |c|
      satisfied =  satified?(c.inhabitant_type(self.speaker), c.inhabitant_type(@subject), c.daytime)
      if((not negate and satisfied) or (negate and not satisfied))
        tmp << c
        @satifying_configurations << c 
      end
    end
    tmp = tmp.uniq
     size = tmp.size
     tmp = tmp.join("\n")
     log "matching compositions \n#{tmp}"
     @satifying_configurations = @satifying_configurations.uniq
     raise "uniq failed expected: \n#{size} \n but was #{@satifying_configurations.size} #{@satifying_configurations}\n" unless @satifying_configurations.size == size
  end
  
  def affected_inhabitants
    [@speaker, @subject].uniq
  end
end

class SubjectTypeExpression < SubjectExpression
  attr_reader  :subject_type
  def initialize speaker, subject, subject_type, negate
    super(speaker, subject, negate)  
    @subject_type = subject_type.to_sym
    calculate_satifying_configurations
  end

  def satified? speaker, subject, daytime
    (speaker == :angel and subject == @subject_type) or
    (speaker == :demon and subject != @subject_type) or
    (speaker == :human and subject == @subject_type and daytime == :day) or
    (speaker == :human and subject != @subject_type and daytime == :night) 
  end
  
  def to_s
   s = "#{@speaker}: #{@subject} is " 
   s += "not " if @negate
   s += "a #{@subject_type}"
  end
end


class DayTimeExpression < SpeakerExpression
  attr_reader :daytime
  def initialize speaker, daytime
    super speaker
    @daytime = daytime.to_sym
    calculate_satifying_configurations
  end
  def calculate_satifying_configurations
     initial_configurations.each do |c|
       if satified?(c.inhabitant_type(@speaker), c.daytime)
         @satifying_configurations << c 
       end
     end
   end
   
   def satified? speaker, daytime
     (speaker == :angel and daytime == @daytime) or
     (speaker == :demon and daytime != @daytime) or
     (speaker == :human and daytime == @daytime and daytime == :day) or
     (speaker == :human and daytime != @daytime and daytime == :night) 
   end
   
  def initial_configurations 
    configurations = []
    AngelsAndDemons.inhabitant_types.each do |speaker_type|  
      configurations << Configuration.new({@speaker => speaker_type}, :day)
      configurations << Configuration.new({@speaker => speaker_type}, :night)   
    end
    configurations.uniq
  end
  
  def to_s
    "It is #{@daytime}" 
  end
end

class SubjectLyingExpression < SubjectExpression
  attr_reader :subject, :negate
  def initialize speaker, subject, negate
      super(speaker, subject, negate)  
      calculate_satifying_configurations
  end
  
  def satified? speaker, subject, daytime
    is_lying = is_lying(subject, daytime)
    (speaker == :angel and is_lying) or
    (speaker == :demon and not is_lying) or
    (speaker == :human and is_lying and daytime == :day) or
    (speaker == :human and not is_lying and daytime == :night) 
  end
   
  def is_lying subject, daytime
    (subject == :demon) or (subject == :human and daytime == :night)
  end
  
  def to_s
   s = "#{@speaker}: #{@subject} is " 
   s += "not " if @negate
   s += "lying"
  end
end

#(input||=[]) << $_.chomp while gets  

input = ["3", "A: B is a human", "B: A is a demon", "A: B is a demon","1", "B: I am an angel",  "1", "A: I am lying", "1", "M: I am a demon",  "0"]
counter = 1
while true
  exit if input[index||=0] =~ /^0$/ 
  if input[index||=0] =~ /^\d+$/  
    puts "Conversation \##{counter}" 
    engine = AngelsAndDemons.new
    result_expression = nil
    1.upto(input[index].to_i) do |i|
      expression_string = input[index+=1]
     # log "INPUT: " + expression_string
      expression = engine.expression_from_string expression_string
      if result_expression
        result_expression = CompositeExpression.new(result_expression, expression) 
      else
        result_expression =  expression
      end
    end
    puts "#{result_expression}"
    puts result_expression.deduct(engine.inhabitants) + "\n\n"
    index += 1
    counter += 1
  end
end
