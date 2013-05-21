require "game_room"

class GameEngine
  attr_accessor :out, :in, :current_room
  def self.instance(*args)
    i = new(*args)
    i.banner
    i.current_room = GameRoom.rooms[:airlock]
    i.run
  end

  def puts(*args)
    @out.puts(*args)
  end

  def actions
    {
      'quit' => "Leave the game",
      'inventory' => "Display your current inventory",
      'equipped' => "Show what you are holding/wearing"
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
  
  def initialize(sin = $stdin, sout = $stdout)
    @in, @out = sin, sout
    @inventory = ["Hairbrush"]
    @equipped = ["Basic Clothes"]
  end

  def inventory(*)
    puts "You are currently carrying:\n#{@inventory.join(',')}"
  end

  def equipped(*)
    puts "You are currenly holding/wearing:\n#{@equipped.join(',')}"
  end

  def display_location
    puts "You are in #{current_room.title}"
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
          @out.printf "%-20s : %s", k, v
        end
      end
    end
  end

  def get_next_command
    @out.print "\n--> "
    @in.gets.chomp.downcase.split(/\s+/)
  end
end
