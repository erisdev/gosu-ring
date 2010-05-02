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
    
    Gosu.enable_undocumented_retrofication rescue nil
    
    icons = Gosu::Image.load_tiles(self, 'data/icons.png', 16, 16, false)
    
    menu = RingMenu.new :radius => 60, :opaque => false, :icon_rotation => 1 do |m|
      m.background :from => 0xd0ffffff, :to => 0xd0000000
      m.font 'Helvetica', 24
      m.item('Quit',   icons[0], :scale => 2) { close }
      m.item('Plus',   icons[1], :scale => 2)
      m.item('Minus',  icons[2], :scale => 2)
      m.item('Coffee', icons[3], :scale => 2) { puts 'Have some coffee.' }
    end
    
    push_game_state BackgroundState.new
    push_game_state menu
    
  end
end

RingDemo.new.show
