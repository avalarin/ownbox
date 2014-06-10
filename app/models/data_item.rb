class DataItem
  attr_reader :name, :path, :full_path, :type, :owner, :permission

  def initialize(h)
    @name = h[:name]
    @path = h[:path]
    @full_path = h[:full_path]
    @owner = h[:owner]
    @permission = h[:permission] || :unknown
  end
end