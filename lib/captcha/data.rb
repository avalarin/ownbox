module Captcha
  class Data
    attr_reader :code, :value

    def initialize code, value
      @code = code
      @value = value
    end

    def save
      return false unless valid?
      Captcha.redis.set code, value
      Captcha.redis.expire code, Captcha.expire
      true
    end

    def delete
      Captcha.redis.del code
    end

    def valid?
      code.present? && value.present?
    end

    def check str
      value == str.delete(" ").upcase
    end

    def url
      '/captcha?code=' + code
    end

    def self.find code
      value = Captcha.redis.get code
      return nil unless value
      Data.new code, value
    end

    def self.generate
      new_code = SecureRandom.uuid
      new_value = ''
      Captcha.length.times{new_value << (65 + rand(26)).chr}
      Data.new new_code, new_value
    end

  end
end