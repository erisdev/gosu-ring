require 'chingu'
require 'ring_menu/hax'

class RingMenu < Chingu::GameState
  autoload :Icon,     'ring_menu/icon'
  autoload :RingList, 'ring_menu/ring_list'
  
  module Z
    BACKGROUND = 0
    ICONS      = 1
    CAPTION    = 2
    CURSOR     = 3
  end
  
  COLORS = {}
  Gosu::Color.constants.each do |name|
    COLORS[name.downcase] = Gosu::Color.const_get name
  end
  
  DEFAULTS = {
    :opaque   => true,
    :rotation => false,
    :radius   => 50,
  }
  
  attr_accessor :x_radius, :y_radius
  
  def initialize options = {}, &block
    super
    
    options = DEFAULTS.merge options
    
    @opaque   = options[:opaque]
    @rotation = options[:icon_rotation]
    @x_radius = options[:x_radius] || options[:radius]
    @y_radius = options[:y_radius] || options[:radius]
    
    @cx = options[:x] || $window.width  / 2
    @cy = options[:y] || $window.height / 2
    
    @rotation = 1 if @rotation and not Numeric === @rotate
    @rotation = 0 if not @rotation
    
    @caption = Chingu::Text.new '',
      :zorder => Z::CAPTION
    
    @items   = RingList[]
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
      :zorder => Z::ICONS
    
    # FIXME when chingu is updated, this should just use the create method
    @items << Icon.new(caption, image, options, &block)
    add_game_object @items.last
    @count = @items.count
  end
  
  def background bg
    @background = case bg
    when Gosu::Color then bg
    when Hash        then bg.merge :zorder => Z::BACKGROUND
    when Array       then { :zorder => Z::BACKGROUND, :colors => bg }
    else Gosu::Color.new(bg)
    end
  end
  
  def cursor image, options = {}
    options.merge! \
      :image  => image,
      :zorder => Z::CURSOR
    @cursor = Chingu::GameObject.new options
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
  
  # utility methods
  
  def close_enough?; @step.abs < 0.1 end
  
  # input methods
  
  def left?; left! if close_enough? end
  def left!
    @items.rotate! +1
    @step -= 1
    update_caption!
  end
  
  def right?; right! if close_enough? end
  def right!
    @items.rotate! -1
    @step += 1
    update_caption!
  end
  
  def perform_action
    @items.first.perform_action
  end
  
  # chingu methods
  
  def update
    super
    
    # update rotation step
    if close_enough?
      @step = 0
    elsif @step < 0
      @step += 0.1
    elsif @step > 0
      @step -= 0.1
    end
    
    # calculate angles for icons
    angle_diff = 2 * Math::PI / @count
    this_angle = angle_diff * @step
    
    # position cursor
    if @cursor
      @cursor.x = @cx
      @cursor.y = @cy - @y_radius
    end
    
    # position icons
    @items.each do |icon|
      icon.x = @cx + @x_radius * Math.sin(this_angle)
      icon.y = @cy - @y_radius * Math.cos(this_angle)
      
      # turn icons if desired
      icon.angle = @rotation * this_angle.radians_to_degrees
      
      this_angle -= angle_diff
    end
  end
  
  def update_caption!
    @caption.text = @items.first.title
    @caption.x    = @cx
    @caption.y    = @cy
  end
  
  def draw
    # draw the previous game state if it is desired
    unless @opaque
      previous_game_state.draw
      $window.flush
    end
    
    super
    
    # draw the background
    # FIXME zorder is ignored by chingu's GFX#fill for colors
    $window.fill @background, Z::BACKGROUND if @background
    
    # draw a cursor if there is one
    @cursor.draw if @cursor
    
    # draw caption if selected item is at the front
    @caption.draw if close_enough?
  end
  
end
