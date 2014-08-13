class DataItem
  attr_reader :name, :path, :full_path, :type, :owner, :permission

  def initialize(h = {})
    @name = h[:name]
    @path = h[:path]
    @full_path = h[:full_path]
    @owner = h[:owner]
    @permission = h[:permission] || :unknown
  end

  def shared?
    return false if (type != 'directory')
    get_attr('ownbox.shared') == 'true'
  end

  def shared= value
    set_attr('ownbox.shared', value ? 'true' : nil)
  end

  def set_attr key, value
    if (!value)
      `attr -r #{key} #{full_path}`   
    else
      `attr -s #{key} -V #{value} #{full_path}`   
    end
  end

  def get_attr key
    `attr -g #{key} #{full_path}` =~ /^.*\n(.*)\n$/
    $1
  end

end