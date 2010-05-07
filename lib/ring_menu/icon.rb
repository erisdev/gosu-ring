class RingMenu
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
end
