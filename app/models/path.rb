class Path
  attr_reader :parts

  def initialize parts, options = nil
    options ||= { }
    @is_rooted = true
    if options.has_key? :rooted
       @is_rooted = options[:rooted]
    end
    @parts = parts
    @path = @parts.join('/')
  end

  def self.parse str
    parts = str.split('/')
    if parts[0] == ''
      is_rooted = true
      parts = parts.slice 1, parts.length - 1 
    else
      is_rooted = false
    end
    Path.new parts, { rooted: is_rooted }
  end

  def is_rooted?
    @is_rooted
  end

  def is_empty?
    @parts.length == 0
  end

  def to_s
    @is_rooted ? '/' + @path : @path
  end

  def to_str
    to_s
  end

  def to_s_non_rooted
    @path
  end

end