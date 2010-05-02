require 'ring_menu'

class RingDemo < Chingu::Window
  def initialize
    super 400, 200, false
    
    icons = Gosu::Image.load_tiles(self, 'data/icons.png', 16, 16, false)
    
    menu = RingMenu.new do |m|
      m.font 'Helvetica', 24
      m.item('Quit',   icons[0]) { close }
      m.item('Plus',   icons[1])
      m.item('Minus',  icons[2])
      m.item('Coffee', icons[3]) { puts 'Have some coffee.' }
    end
    
    push_game_state menu
    
  end
end

RingDemo.new.show
