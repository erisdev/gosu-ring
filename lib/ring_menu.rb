require 'chingu'

class RingMenu < Chingu::GameState
  class Icon < Chingu::GameObject
    attr_accessor :title
    
    def initialize title, image, options = {}, &block
      super options.merge(:image => image, :center => 0.5)
      @title  = title
      @action = block
      
      # make actionless icons transparent while preserving color
      @color.alpha /= 2 unless @action
    end
    
    def perform_action
      @action[self] if @action
    end
    
  end
  
  module Z
    BACKGROUND = 0
    ICONS      = 1
    CAPTION    = 2
  end
  
  COLORS = {}
  Gosu::Color.constants.each do |name|
    COLORS[name.downcase] = Gosu::Color.const_get name
  end
  
  DEFAULTS = {
    :opaque   => true,
    :rotation => false,
    :radius   => 50,
    :z_base   => 100
  }
  
  def initialize options = {}, &block
    super
    
    options = DEFAULTS.merge options
    
    @opaque   = options[:opaque]
    @rotation = options[:icon_rotation]
    @radius   = options[:radius]
    @z_base   = options[:z_base]
    
    @rotation = 1 if @rotation and not Numeric === @rotate
    @rotation = 0 if not @rotation
    
    @caption = Chingu::Text.new '', :zorder => @z_base + Z::CAPTION
    @items   = []
    @index   = 0
    @step    = 0
    
    # FIXME when chingu is updated, just pass :center => 0.5
    @caption.center = 0.5
    
    self.input = {
      :left  => :left!,  :holding_left  => :left?,
      :right => :right!, :holding_right => :right?,
      
      :return => :perform_action
    }
    
    yield self if block_given?
    update_caption!
  end
  
  # constructor methods
  
  def item caption, image, options = {}, &block
    options.merge! \
      :zorder => @z_base + Z::ICONS
    
    # FIXME when chingu is updated, this should just use the create method
    @items << Icon.new(caption, image, options, &block)
    add_game_object @items.last
    @count = @items.count
  end
  
  def background bg
    @background = case bg
    when Gosu::Color then bg
    when Hash        then bg.merge :zorder => @z_base + Z::BACKGROUND
    when Array       then { :zorder => @z_base + Z::BACKGROUND, :colors => bg }
    else Gosu::Color.new(bg)
    end
  end
  
  def font name, height
    name, height = height, name if Numeric === name
    
    # FIXME would be great to do this, but chingu doesn't allow it (yet)
    # @caption.font   = name   if name
    # @caption.height = height if height
    
    # do it the hard way!
    @caption.instance_eval do
      @font   = name   if name
      @height = height if height
      create_image
    end
  end
  
  # input methods
  
  def left?; left! if @index == @step end
  def left!
    @index -= 1
    if @index < 0
      @index += @count
      @step  += @count
    end
    update_caption!
  end
  
  def right?; right! if @index == @step end
  def right!
    @index += 1
    if @index >= @count
      @index -= @count
      @step  -= @count
    end
    update_caption!
  end
  
  def perform_action
    @items[@index].perform_action
  end
  
  # chingu methods
  
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
    
    # calculate angles for icons
    angle_diff = 2 * Math::PI / @count
    this_angle = angle_diff * @step
    
    # position caption and icons
    @caption.x = cx
    @caption.y = cy
    @items.each do |icon|
      icon.x = cx + @radius * Math.sin(this_angle)
      icon.y = cy - @radius * Math.cos(this_angle)
      
      # turn icons if desired
      icon.angle = @rotation * this_angle.radians_to_degrees
      
      this_angle -= angle_diff
    end
  end
  
  def update_caption!
    @caption.text = @items[@index].title
  end
  
  def draw
    super
    
    # draw the previous game state if it is desired
    previous_game_state.draw unless @opaque
    
    # draw the background
    # FIXME zorder is ignored by chingu's GFX#fill for colors
    $window.fill @background, @z_base + Z::BACKGROUND if @background
    
    # draw caption if selected item is at the front
    @caption.draw if @index == @step
  end
  
end
