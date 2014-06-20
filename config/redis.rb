require "redis"

class Redis
  @@instance = Redis.new path: "/tmp/redis.sock"
  def self.instance
    @@instance
  end
end