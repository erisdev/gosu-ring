# this will be here until Gosu goes live with Window#flush

class Gosu::Window
  unless instance_methods.collect(&:to_s).include? 'flush'
    def flush; gl { } end
  end
end