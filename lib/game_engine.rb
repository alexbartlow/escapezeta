require "game_room"
require 'utils'

class GameEngine
  include Utils
  attr_accessor :out, :in, :current_room
  def self.instance(*args)
    i = new(*args)
    i.banner
    i.current_room = GameRoom.rooms[:airlock]
    i.run
  end

  def initialize(sin = $stdin, sout = $stdout)
    @in, @out = sin, sout
    @inventory = ItemSet.new(["Hairbrush"])
    @equipped = ItemSet.new(["Basic Clothes"])
  end

  def puts(*args)
    @out.puts(*args)
  end

  def actions
    {
      'quit' => "Leave the game",
      'inventory' => "Display your current inventory",
      'carried' => "Show what you are holding/wearing",
      'grab' => "Grab an item and put it in your inventory",
      'pitch' => "Drop an item from your inventory",
      'equip' => "Equip an item you have in your inventory",
      'takeoff' => "Unequip an item"
    }.merge(current_room.actions)
  end
  %w{left right up down}.each do |direction|
    define_method direction do
      @current_room = current_room.exits[direction]
    end
  end

  def display_actions
    puts "Possible actions are: #{actions.keys.join(',')}"
  end

  def display_exits
    puts "Possible exits are #{current_room.exits.keys.join(', ')}"
  end

  def banner
    puts "Your adventure is now beginning..."
  end

  def quit(*)
    @running = false
  end
  

  def inventory(*)
    puts "You are currently carrying:\n#{@inventory.map(&:upcase).join("\n")}"
  end

  def carried(*)
    puts "You are currenly holding/wearing:\n#{@equipped.map(&:upcase).join("\n")}"
  end

  def grab(item, *args)
    if picked_item = current_room.items.pluck(item)
      puts "Picked up #{picked_item.upcase}."
      @inventory << picked_item
      current_room.items.delete picked_item
    else
      puts "No item like #{item} to grab."
    end
  end

  def pitch(item, *args)
    if picked_item = @inventory.pluck(item)
      puts "Dropped #{picked_item.upcase}"
      @inventory.delete picked_item
      current_room.items << picked_item
    else
      puts "No item like #{item} to drop."
    end
  end

  def equip(item, *args)
    if picked_item = @inventory.pluck(item)
      puts "Equipped #{picked_item.upcase}"
      @inventory.delete picked_item
      @equipped << picked_item
    else
      puts "No item like #{item} to equip."
    end
  end

  def takeoff(item, *args)
    if picked_item = @equipped.pluck(item)
      puts "Took off #{picked_item.upcase}"
      @equipped.delete picked_item
      @inventory << picked_item
    else
      puts "Not wearing anything like #{item}."
    end
  end

  def display_location
    puts "You are in #{current_room.title}"
    if current_room.items.size > 0
      puts "It contains #{current_room.items.map(&:upcase).join(', ')}"
    else
      puts "It contains nothing of interest."
    end
  end

  def run
    @running = true
    while @running do
      display_location
      display_actions
      display_exits
      command, *arguments = get_next_command
      if actions.keys.include?(command) || current_room.exits.has_key?(command)
        self.send(command, *arguments)
      else
        @out.puts %{Don't understand #{command}, options are}
        actions.each do |k,v|
          @out.printf "%-20s : %s\n", k, v
        end

        puts "Exits are:"
        puts current_room.exits.keys.map(&:upcase).join(', ')
      end
    end
  end

  def get_next_command
    @out.print "\n--> "
    command, *args = @in.gets.chomp.downcase.split(/\s+/)
    possible = actions.keys.grep(/^#{command}/) +
      current_room.exits.keys.grep(/^#{command}/)
    if possible.size == 1
      command = possible[0]
    end
    return command, *args
  end
end
