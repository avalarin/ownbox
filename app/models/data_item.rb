class DataItem
  attr_reader :name, :path, :full_path, :type, :owner

  def initialize(h)
    @name = h[:name]
    @path = h[:path]
    @full_path = h[:full_path]
    @owner = h[:owner]
  end
end