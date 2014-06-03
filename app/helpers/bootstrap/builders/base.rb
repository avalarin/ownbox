module Bootstrap
  module Builders
    class Base
      def initialize template, options, &block
        @template = template
        @options = options || {}
        @block = block
      end

      def render

      end

      protected

      def template
        @template
      end

      def options
        @options
      end

      def block
        @block
      end

      def capture_content
        block ? template.capture(self, &block) : ""
      end

      def get_html_attributes base_css = "", from_options = [], options = {}
        html = options[:html] || {}
        if html[:class] && base_css
          html[:class] = base_css + " " + html[:class]
        elsif base_css
          html[:class] = base_css
        end
        from_options.each { |e| html[e] ||= options[e] }
        if (options[:data] && options[:data].class == Hash)
          options[:data].each do |k, v|
            html["data-" + k.to_s] = v
          end
        end
        html
      end


    end
  end
end