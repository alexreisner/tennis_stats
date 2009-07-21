class Player
  attr_reader :name, :handle
  
  def initialize(handle, name = nil)
    @handle = handle
    @name = name
  end
  
  def to_s
    name
  end
end

