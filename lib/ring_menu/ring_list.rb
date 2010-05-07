class RingMenu
  class RingList < Array
    
    def rotate! n = 1
      if n >= 0 then push    *shift(n)
      else           unshift *pop(-n)
      end
    end
    
    def rotate n
      clone.rotate! n
    end
    
  end
end
