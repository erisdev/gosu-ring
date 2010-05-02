require 'chingu'

class RingMenu < Chingu::GameState
  class Icon < Chingu::GameObject
    attr_accessor :title
    
    def initialize title, image, options = {}, &block
      super options.merge(:image => image)
      @title  = title
      @action = block
      
      # make actionless icons transparent while preserving color
      @color.alpha /= 2 unless @action
    end
    
    def perform_action
      @action[self] if @action
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
      :left  => :left!,  :holding_left  => :left?,
      :right => :right!, :holding_right => :right?,
      
      :return => :perform_action
    }
    
    yield self if block_given?
  end
  
  def item caption, image, options = {}, &block
    # FIXME when chingu is updated, this should just use the create method
    @items << Icon.new(caption, image, options, &block)
    add_game_object @items.last
    @count = @items.count
  end
  
  def left?; left! if @index == @step end
  def left!
    @index -= 1
    if @index < 0
      @index += @count
      @step  += @count
    end
  end
  
  def right?; right! if @index == @step end
  def right!
    @index += 1
    if @index >= @count
      @index -= @count
      @step  -= @count
    end
  end
  
  def perform_action
    @items[@index].perform_action
  end
  
  def update
    super
    
    # update rotation step
    if (@step - @index).abs < 0.1
      @step = @index
    elsif @step < @index
      @step += 0.1
    elsif @step > @index
      @step -= 0.1
    end
    
    cx = $window.width / 2
    cy = $window.height / 2
    
    angle_diff = 2 * Math::PI / @count
    this_angle = angle_diff * @step
    
    @items.each do |icon|
      icon.x = cx + @radius * Math.sin(this_angle)
      icon.y = cy - @radius * Math.cos(this_angle)
      this_angle += angle_diff
    end
  end
  
end
