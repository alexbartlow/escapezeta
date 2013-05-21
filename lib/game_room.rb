class GameRoom
  attr_accessor :exits, :items, :title, :actions
  def initialize(title="An Empty Room")
    @title = title
    @exits = {}
    @items = []
    @actions = {}
  end
  
  def left=(aRoom)
    @exits['left'] = aRoom
    aRoom.exits['right'] = self
  end

  def up=(aRoom)
    @exits['up'] = aRoom
    aRoom.exits['down'] = self
  end

  def down=(aRoom)
    @exits['down'] = aRoom
    aRoom.exits['up'] = self
  end

  def right=(aRoom)
    @exists['right'] = aRoom
    aRoom.exits['left'] = self
  end

  def self.rooms
    @rooms ||= Hash.new do |hsh, k|
      r = GameRoom.new
      r.title = "The #{k.to_s}"
      hsh[k] = r
    end
  end
end
airlock = GameRoom.rooms[:airlock]
airlock.title = "the airlock to a derelict space station."

mess_hall = GameRoom.rooms[:mess_hall]
mess_hall.title = "a dirty mess call that smells of old cheese."

science_lab = GameRoom.rooms[:science_lab]

crew_quarters = GameRoom.rooms[:crew_quarters]

launch_control = GameRoom.rooms[:launch_control]

launch_pad = GameRoom.rooms[:launch_pad]

rocket = GameRoom.rooms[:rocket]

airlock.left = mess_hall
mess_hall.up = science_lab
mess_hall.left = crew_quarters

crew_quarters.down = launch_control
crew_quarters.left = launch_pad

launch_pad.left = rocket
