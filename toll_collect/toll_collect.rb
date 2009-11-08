#/usr/bin/ruby

class Link
  attr_reader :node, :cost
  def initialize node, cost
     @node = node and @cost = cost
  end
end

class Engine
  def add_node x, y, z
    (x, y) = [y, x] if y < x
    @first_node = [@first_node||=x, x].min
    @nodes = [] unless @nodes
    (@nodes[x] ||= []) << Link.new(y, z)
  end
  def run
    recurse(@first_node).max
  end
  def recurse x
    (total, max) = [0,0];
    if @nodes[x]
      @nodes[x].each do |link| 
        (t,m) = recurse link.node
        total += (t + link.cost) if t + link.cost > 0
        max = [m, t, max].max
      end 
    end   
    [total, max]
  end
end

(input||=[]) << $_.chomp while gets  
while true
  exit if input[index||=0] =~ /^0$/ 
  if input[index||=0] =~ /^\d+$/  
    engine = Engine.new
    1.upto(input[index].to_i) do |i|
      engine.add_node *input[index+=1].split(/\s+/).map{|s| s.to_i}
    end
    puts engine.run
    index += 1
  end
end

