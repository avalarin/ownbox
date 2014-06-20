module Captcha
  class Middleware
    include Captcha::ImageHelpers
    
    DEFAULT_SEND_FILE_OPTIONS = {
      :type         => 'application/octet-stream'.freeze,
      :disposition  => 'attachment'.freeze,
    }.freeze
    
    def initialize(app, options={})
      @app = app
      self
    end
    
    def call(env)
      request = Rack::Request.new(env)
      if request.get? && render_captcha_path?(request)
        return make_image(request)
      elsif request.post?
        if new_captcha_path?(request)
          return make_captcha(request)
        elsif check_captcha_path?(request)
          return check_captcha(request)
        end
      end
      @app.call(env)
    end
    
    protected
      def make_image(request)
        headers = { }
        status = 404
        code = request.params["code"]
        body = []
        
        unless code.blank?
          data = Data.find code      
          if data 
            return send_file generate_captcha_image(data.value), :type => 'image/jpeg', 
              :disposition => 'inline', :filename =>  'captcha.jpg'
          end
        end
        
        [status, headers, body]
      end
      
      def make_captcha(request)
        status = 400
        captcha = Captcha::Data.generate
        captcha.save
        body = [ { status: 200, data: { code: captcha.code, url: captcha.url } }.to_json ]
        headers = { 
          "Content-Type" => "application/json", 'Cache-Control' => 'private'
        }
        [200, headers, body]
      end

      def check_captcha(request)
        headers = { 
          "Content-Type" => "application/json", 'Cache-Control' => 'private'
        }
        status = 404
        data = nil
        if (['application/json', 'text/json'].include? request.content_type.downcase)
          data = JSON.parse(request.body.read)
        else
          data = request.POST
        end
        return [ 400, headers, [{ status: 400, message: 'bad_request', data: data }.to_json] ] unless data && data['code'] && data['value']
        captcha = Captcha::Data.find data['code']
        return [ 404, headers, [{ status: 400, message: 'not_found' }.to_json] ] unless captcha
        if (captcha.check data['value'])
          return [ 200, headers, [{ status: 200, message: 'ok' }.to_json] ]
        else
          return [ 400, headers, [{ status: 400, message: 'invalid_captha' }.to_json] ]
        end
      end

      def render_captcha_path?(request)
        request.path_info.start_with? '/captcha'
      end

      def check_captcha_path?(request)
        request.path_info.start_with? '/captcha/check'
      end

      def new_captcha_path?(request)
        request.path_info.start_with? '/captcha/new'
      end
      
      def send_file(path, options = {})
        raise MissingFile, "Cannot read file #{path}" unless File.file?(path) and File.readable?(path)
        options[:filename] ||= File.basename(path) unless options[:url_based_filename]
        status = options[:status] || 200
        headers = {
          "Content-Disposition" => "#{options[:disposition]}; filename='#{options[:filename]}'", 
          "Content-Type" => options[:type], 'Content-Transfer-Encoding' => 'binary', 'Cache-Control' => 'private'
        }
        response_body = File.open(path, "rb")
        [status, headers, response_body]
      end
  end
end