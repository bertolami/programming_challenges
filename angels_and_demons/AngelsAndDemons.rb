#/usr/bin/ruby

def log s
  puts s.to_s
end
class AngelsAndDemons


  def self.inhabitant_types
    [:angel, :demon, :human]
  end
  
  def self.daytime_types
    [:day, :night]
  end

  def self.expression_from_string string
    (speaker, rest) = string.split ':'
    negate = rest.include? "not"
    rest.delete "not" if negate
    if rest.include? "is a"
      (subject, type) = rest.split " is a "
      SubjectTypeExpression.new speaker, subject, type, negate
    elsif rest.include? "I am a"
      type = rest.split(" ").pop
      SubjectTypeExpression.new speaker, speaker, type, negate
    elsif rest.include? "I am lying"
      SubjectLyingExpression.new speaker, speaker, negate
    elsif rest.include? "is lying"
      subject = rest.split(" ").shift
      SubjectLyingExpression.new speaker, subject, negate
    elsif rest.include? "It is"
      daytime = rest.split(" ").shift
      DayTimeExpression.new speaker, daytime
    else
      puts "NOT ABLE TO PARSE #{string}"
    end
  end
end



class Expression
  attr_accessor :speaker, :speaker_type, :daytime_satifying_configurations
  
  def initialize
    @daytime_satifying_configurations = {}
  end

end

class Configuration
  def initialize inhabitant_types
    @inhabitant_types = inhabitant_types
  end
  
  def inhabitants
    @inhabitant_types.keys
  end

  def inhabitant_type inhabitant
    @inhabitant_types[inhabitant]
  end
  
  def == c
    @inhabitant_types == c.inhabitant_types
  end
  
  def to_s
    @inhabitant_types.keys.each do |key|
      s += (" #{key} => "+ @inhabitant_types[key].to_s)
    end
    s
  end
end

class SubjectTypeExpression < Expression
  attr_reader :subject, :subject_type, :negate
  def initialize(speaker, subject, subject_type, negate)
    @negate = negate
    @subject = subject.to_sym
    @subject_type = subject_type.to_sym
    self.speaker = speaker.to_sym
  end

  def initial_configurations 
    configurations = []
    affected_inhabitants.each do |speaker|
      AngelsAndDemons.inhabitant_types.each do |speaker_type|  
        affected_inhabitants.each do |subject|
          AngelsAndDemons.inhabitant_types.each do |subject_type|  
            configurations << Configuration.new({speaker => speaker_type, subject => subject_type})
          end
        end
      end
    end
    configurations.uniq
  end

  def affected_inhabitants
    [@speaker, @subject].uniq
  end

  def satifying_configurations
    log " satifying_configurations" 
    initial_configurations.each do |c|
      AngelsAndDemons.daytime_types.each do |daytime|
        log "adding #{c} #{daytime}" 
        self.satifying_configurations{daytime} << c if satified?(c.inhabitant_type(self.speaker), c.inhabitant_type(@subject), daytime)
      end
    end
   end

  def satified? speaker, subject, daytime
    (speaker == :angel and subject == @subject_type) or
    (speaker == :demon and subject != @subject_type) or
    (speaker_type == :human and (subject == @subject_type and daytime == :day or  
    subject != @subject_type and daytime == :night))
  end

  def to_s
    puts satifying_configurations
    "#{@speaker}: " + (@negate ? "not" : "") + "#{@subject} is a #{@subject_type}"
  end
end


class DayTimeExpression < Expression
  attr_reader :daytime
  def initialize(daytime)
    @daytime = daytime.to_sym
  end
  def affected_inhabitants
    [@speaker]
  end
end

class SubjectLyingExpression < Expression
  attr_reader :subject, :negate
  def initialize(speaker, subject, negate)
    self.speaker = speaker.to_sym
    @subject = subject.to_sym
    @negate = negate
  end
  def affected_inhabitants
    [@subject, @speaker].uniq
  end
  def to_s
    "#{@speaker}: #{@subject} is " + (@negate ? "not" : "") + " lying"
  end
end

#(input||=[]) << $_.chomp while gets  

input = ["1", "B: I am an angel", "1", "A: I am lying", "3", "A: B is a human", "B: A is a demon", "A: B is a demon", "0"]
while true
  exit if input[index||=0] =~ /^0$/ 
  if input[index||=0] =~ /^\d+$/  
    puts "---- #{input[index]} rules -----"
    1.upto(input[index].to_i) do |i|
      expression_string = input[index+=1]
      log "INPUT: " + expression_string
      expression = AngelsAndDemons.expression_from_string expression_string
      log expression
    end
    index += 1
  end
end
