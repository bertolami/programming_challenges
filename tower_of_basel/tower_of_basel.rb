#/usr/bin/ruby

def log string
  puts "- #{string}"
end

class Block
  attr_reader :x, :y, :z
  
  def initialize(x, y, z)
    @x = x ;  @y = y;  @z = z
  end
  
  def Block::positionable_blocks x,y,z
    set = []
    set << block_with_x_larger_than_y(x, y, z)
    set << block_with_x_larger_than_y(x, z, y)
    set << block_with_x_larger_than_y(y, z, x)
  end
  
  def Block::block_with_x_larger_than_y x,y,z
     x >= y ? Block.new(x, y, z) :  Block.new(y, x, z)
  end
    
end

class TreeItem
  attr_reader :block, :height
  attr_accessor :open_list
  
  def initialize block, height
    @block = block
    @height = height
  end
  
end

class TowerOfBasel
  attr_reader :expanded_items
  
  def initialize initial_blocks
    @current_tree_items = []
    @max_height = 0
    initial_blocks.each do |block|
      tree_item = TreeItem.new block, block.z
      if necessary? tree_item
        tree_item.open_list = next_open_list initial_blocks, block
        @current_tree_items << tree_item 
      end
    end
    remove_unnecessary   
    @expanded_items = @current_tree_items.size
    @current_tree_items.each do |tree_item|
      log "starting with (#{tree_item.block.x} #{tree_item.block.y} #{tree_item.block.z})"
    end 
  end
  
  def build_tower 
    while tree_item = @current_tree_items.shift
      next_blocks(tree_item.open_list).each do |block|
        next_tree_item = TreeItem.new(block, tree_item.height + block.z) 
        if necessary? next_tree_item
          @expanded_items += 1
          next_tree_item.open_list = next_open_list(tree_item.open_list, block)     
          if next_tree_item.open_list.size > 0
            @current_tree_items << next_tree_item 
            log "(#{block.x} #{block.y} #{block.z}) on top of (#{tree_item.block.x} #{tree_item.block.y} #{tree_item.block.z})"
            remove_unnecessary
          else
            log "(#{block.x} #{block.y} #{block.z}) on top of (#{tree_item.block.x} #{tree_item.block.y} #{tree_item.block.z}) provides height #{next_tree_item.height}"
            @max_height = next_tree_item.height if next_tree_item.height > @max_height
          end
        end
      end
    end
    @max_height
  end
  
  private
  
  def necessary? t1
    @current_tree_items.each { |t2| return false if t2.height >= t1.height && t2.block.x >= t1.block.x && t2.block.y >= t1.block.y }
    true
  end

  def remove_unnecessary
    unnecessary = []
    @current_tree_items.size.times do |i|
      t1 = @current_tree_items[i]
      (i+1).upto(@current_tree_items.size-1) do |j|
        t2 = @current_tree_items[j]
        if t2.height >= t1.height && t2.block.x >= t1.block.x && t2.block.y >= t1.block.y
     #     log "neglecting (#{t1.block.x} #{t1.block.y} #{t1.block.y})"
          unnecessary << i
          break
        end
      end
    end
    unnecessary.reverse.each do |item|
       @current_tree_items.delete_at item
    end
  end
  
  def next_blocks open_list
    next_items = []
    open_list.size.times do |i|
      b1 = open_list[i]
      ok = true
      (i+1).upto(open_list.size-1) do |j| 
        b2 = open_list[j]
        if (b1.x < b2.x && b1.y < b2.y) or  (b1.x == b2.x && b1.y == b2.y and b2.z >= b1.z)
          ok = false
          break
        end
      end
      next_items << b1 if ok
    end
    next_items
  end
  
  def next_open_list initial_blocks, block
    open_list = []
    initial_blocks.each { |open| open_list << open if open.x < block.x && open.y < block.y }
    open_list
  end
end

input = []
while gets
   input << $_.chomp 
end

index = 0
caze = 0
while true
  exit if input[index] =~ /^0$/ 
  if input[index] =~ /^\d+$/  
    initial_blocks = []
    n = input[index].to_i
    caze += 1
    1.upto(n) do |i|
      index += 1
      (x,y,z) = input[index].split(/\s+/).map{|s| s.to_i}
      Block::positionable_blocks(x,y,z).each do |block|
        initial_blocks << block
      end
    end
    tower_of_basel = TowerOfBasel.new initial_blocks
    height = tower_of_basel.build_tower
    puts "Case #{caze}: maximum height = #{height} (expanded nodes = #{tower_of_basel.expanded_items} for #{n} blocks)"
    index += 1
  end
end



