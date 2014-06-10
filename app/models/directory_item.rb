class DirectoryItem < DataItem
  attr_reader :directory_type

  def initialize(h)
    super
    @type = 'directory';
    @directory_type = h[:directory_type] || :general
  end



end