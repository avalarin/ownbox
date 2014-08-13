require 'thread'

class PreviewManager

  class << self
    @@mutex = Mutex.new
    @@queue = Queue.new
    @@tasks = {}
    @@processor = nil

    def get item, size
      raise ArgumentError, "Invalid preview size #{size}." unless (Settings.previews.sizes.include? size)
      path = get_privew_file_path(item, size)
      if File.exist? path
        return {
          path: path,
          exist: true
        }
      end
      if !@@tasks.has_key? path
        add_task(item, path, size) 
      end
      return {
        path: path,
        exist: false
      }
    end

    private

    def add_task item, out_path, size
      task = {
        full_path: item.full_path,
        size: size,
        out_path: out_path
      }
      @@queue.push(task)
      @@tasks[out_path] = task
      unless @@processor
        @@mutex.synchronize do
          unless @@processor
            Rails.logger.info "[Previews] Start new previews processor thread"
            @@processor = Thread.new do
              while @@queue.size > 0
                task = @@queue.pop
                start = Time.now
                create_preview(task[:full_path], task[:out_path], task[:size])
                elapsed = ((Time.now.to_f - start.to_f) * 1000.0).round(1)
                Rails.logger.info "[Previews] Preview for #{task[:full_path]} with size #{task[:size]} generated in #{elapsed}ms."
                @@tasks.delete(task[:out_path])
              end
              @@processor = nil
              Rails.logger.info "[Previews] All previews generated"
            end
          end
        end
      end
    end

    def create_preview from, to, size
      image = MiniMagick::Image.open from
      image.resize size
      path = File.dirname to
      FileUtils.mkdir_p path unless File.directory? path
      image.write to
    end

    def get_privew_file_path item, size
      item_path = item.path.to_s
      dirname = File.dirname(item_path)
      extension = File.extname(item_path)
      basename = File.basename(item_path, extension)
      path = "#{item.owner.name}/#{dirname}/#{basename}[___#{size}___]#{extension}"
      File.join(File.expand_path(Settings.previews.directory), path)
    end

  end

end