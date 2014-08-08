class DirectoryItem < DataItem
  attr_reader :directory_type

  def initialize(h = {})
    @directory_type = h[:directory_type] || :general
    h.delete(:directory_type)
    h[:type] = 'directory'
    super h
  end

end