require 'rubygems'
require 'zip'

class Ziper

  class << self
    @@threads = {}

    def create user, item, filters
      id = SecureRandom.uuid

      result_name = item.name + ".zip"
      zip_name = id + ".zip"
      zip_directory = File.join(File.expand_path(Settings.zip_storage_path), user.name)
      FileUtils.mkdir_p(zip_directory) unless File.directory?(zip_directory)
      zip_file_name = File.join(zip_directory, zip_name)
      
      if (filters.size > 0)
        directories = filters.map { |f| File.join(item.full_path, f) }
      else
        directories = [ File.join(item.full_path, '**', '**') ]
      end

      params = { directory: item.full_path, filter: directories, zip_file_name: zip_file_name,
                 result_name: result_name, user: user } 

      thread = Thread.new(params) do |p|
        begin
          current_thread = Thread.current
          current_thread[:stop] = false
          current_thread[:status] = :progress
          current_thread[:progress] = 0
          current_thread[:user] = p[:user].id
          current_thread[:name] = p[:result_name]
          current_thread[:path] = p[:zip_file_name]
          current_thread[:count] = -1
          current_thread[:current] = -1
          current_thread[:debug] = {
            filter: p[:filter]
          }
          p[:directory] << "/" if (p[:directory][-1] != '/')
          Zip::File.open(p[:zip_file_name], Zip::File::CREATE) do |zipfile|
            current_thread[:debug][:files] = nil
            files = Dir.glob(p[:filter], 0)
            current_thread[:count] = files.count
            current_thread[:current] = 0
            current_thread[:debug][:files] = files
            files.each do |file|
              break if (current_thread[:stop] == true)
              local_path = file.sub(p[:directory], '')
              zipfile.add(local_path, file)
              current_thread[:current] += 1
              current_thread[:progress] = current_thread[:current] * 100 / current_thread[:count]
            end
          end
          current_thread[:progress] = 100
          current_thread[:status] = :completed
        rescue Exception => e
          logger.error "Fatal error when creating an zip archive: #{e.inspect}"
          current_thread[:status] = :error
          current_thread[:exception] = e
        end
      end
      @@threads[id] = thread

      return { id: id, name: result_name }
    end

    def status user, id
      thread = @@threads[id] 
      return { status: :not_found } unless thread
      return { status: :invalid_user } unless thread[:user] == user.id
      return { status: thread[:status], progress: thread[:progress], count: thread[:count], current: thread[:current], debug: thread[:debug]  }
    end

    def get user, id
      thread = @@threads[id] 
      raise ArgumentError, 'Task not found' unless thread && thread[:user] == user.id
      raise ArgumentError, 'Task not completed' unless thread[:status] == :completed
      return { path: thread[:path], filename: thread[:name] }
    end

    def delete user, id
      thread = @@threads[id] 
      raise ArgumentError, 'Task not found' unless thread && thread[:user] == user.id
      thread[:stop] = true
      thread.join
      path = thread[:path]
      File.delete(path) if (File.exist?(path))
    end

  end

end