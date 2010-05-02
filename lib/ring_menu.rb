require 'chingu'

class RingMenu < Chingu::GameState
  class Icon < Chingu::GameObject
    attr_accessor :title
    
    def initialize title, image, options = {}, &block
      super options.merge(:image => image)
      @title  = title
      @action = block
      puts "Created #{self} (#{title}) -> #{block}"
    end
    
    def perform_action
      @action[self]
    end
  end
  
  DEFAULTS = { :radius => 50 }
  
  def initialize options = {}, &block
    super
    
    options = DEFAULTS.merge options
    @radius = options[:radius]
    
    @items = []
    @index = 0
    @step  = 0
    
    self.input = {
      :left  => :left!,
      :right => :right!,
      :return => :act!
    }
    
    yield self if block_given?
  end
  
  def item caption, image, options = {}, &block
    # FIXME when chingu is updated, this should just use the create method
    @items << Icon.new(caption, image, options, &block)
    add_game_object @items.last
  end
  
  def left!
    @index -= 1
    @index  = @items.count - 1 if @index < 0
  end
  
  def right!
    @index += 1
    @index  = 0 if @index >= @items.count
  end
  
  def act!
    @items[@index].perform_action
  end
  
  def update
    super
    
    cx = $window.width / 2
    cy = $window.height / 2
    
    angle_step = 2 * Math::PI / @items.count
    angle      = angle_step * @index
    @items.each do |icon|
      icon.x = cx + @radius * Math.sin(angle)
      icon.y = cy - @radius * Math.cos(angle)
      angle += angle_step
    end
  end
  
end
