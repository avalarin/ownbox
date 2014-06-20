module Captcha

  autoload :Utils,        'captcha/image'
  autoload :Data,         'captcha/data'
  autoload :ImageHelpers,      'captcha/image'
  autoload :Middleware,   'captcha/middleware'

  mattr_accessor :image_size
  @@image_size = "150x50"

  mattr_accessor :length
  @@length = 6

  # 'embosed_silver',
  # 'simply_red',
  # 'simply_green',
  # 'simply_blue',
  # 'distorted_black',
  # 'all_black',
  # 'charcoal_grey',
  # 'almost_invisible'
  # 'random'
  mattr_accessor :image_style
  @@image_style = 'all_black'

  # 'low', 'medium', 'high', 'random'
  mattr_accessor :distortion
  @@distortion = 'medium'

  # command path
  mattr_accessor :image_magick_path
  @@image_magick_path = ''

  # tmp directory
  mattr_accessor :tmp_path
  @@tmp_path = Dir::tmpdir

  # point size
  mattr_accessor :point_size
  @@point_size = 32

  mattr_accessor :redis
  @@redis = Redis.instance

  mattr_accessor :expire
  @@expire = 3600

end