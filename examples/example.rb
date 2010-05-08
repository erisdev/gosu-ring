require 'ring_menu'

class BackgroundState < Chingu::GameState
  def initialize
    super
    Chingu::GameObject.create \
      :image  => Gosu::Image.new($window, 'data/icons.png', false),
      :center => 0.5,
      :x      => $window.width  / 2,
      :y      => $window.height / 2,
      :scale  => 4,
      :zorder => 1
  end
end

class RingDemo < Chingu::Window
  def initialize
    super 400, 200, false
    
    self.caption = 'Ring Menu'
    self.input   = {
      :q => proc { @menu.instance_eval { @rotation -= 1 } },
      :w => proc { @menu.instance_eval { @rotation += 1 } },
      
      :holding_a => proc { @menu.x_radius -= 8 },
      :holding_s => proc { @menu.x_radius += 8 },
      
      :holding_z => proc { @menu.y_radius -= 8 },
      :holding_x => proc { @menu.y_radius += 8 },
      
      :escape => :close
    }
    
    Gosu.enable_undocumented_retrofication rescue nil
    
    cursor = Gosu::Image.new(self, 'data/cursor.png')
    icons  = Gosu::Image.load_tiles(self, 'data/icons.png', 16, 16, false)
    
    @menu = RingMenu.new :radius => 60, :opaque => false, :icon_rotation => 1, 
      :x_radius => 100, :y_radius => 50 do |m|
      m.background :from => 0xd0ffffff, :to => 0xd0000000
      m.cursor cursor, :scale => 2
      m.font 'Helvetica', 24
      
      m.item('Quit',    icons[0], :scale => 2) { close }
      m.item('Plus',    icons[1], :scale => 2)
      m.item('Minus',   icons[2], :scale => 2)
      m.item('Coffee',  icons[3], :scale => 2) { @status.text = 'Have some coffee.' }
      m.item('Feather', icons[4], :scale => 2) { @status.text = "It's a feather." }
      m.item('Ball',    icons[5], :scale => 2)
    end
    
    @messages = [
      'R, Q : icon rotation factor ',
      'A, S : horizontal radius ',
      'Z, X : vertical radius ',
    ].map.with_index do |message, line|
      Chingu::Text.create message,
        :x      => 18,
        :y      => 18 * (line + 1),
        :height => 18
    end
    
    push_game_state BackgroundState.new
    push_game_state @menu
    
  end
  
end

RingDemo.new.show
