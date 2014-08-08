class Path
  attr_reader :parts

  def initialize parts, options = nil
    options ||= { }
    @rooted = true
    if options.has_key? :rooted
       @rooted = options[:rooted]
    end
    @parts = parts
    @path = @parts.join('/')
  end

  def self.parse str
    parts = str.split('/')
    if parts[0] == ''
      rooted = true
      parts = parts.slice 1, parts.length - 1 
    else
      rooted = false
    end
    Path.new parts, { rooted: rooted }
  end

  def rooted?
    @rooted
  end

  def empty?
    @parts.length == 0
  end

  def +(b)
    if (b.is_a? Path)
      Path.new(self.parts + b.parts, rooted: self.rooted?)
    else
      self + Path.parse(b)
    end
  end

  def to_s
    rooted? ? '/' + @path : @path
  end

  def to_str
    to_s
  end

  def to_s_non_rooted
    @path
  end

  def to_s_rooted
    '/' + @path
  end

end