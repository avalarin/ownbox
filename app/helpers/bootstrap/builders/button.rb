module Bootstrap
  module Builders
    class Button < Base

      def render
        options[:style] ||= :default
        options[:size] ||= :default

        content = options[:text] || capture_content

        if (options[:icon])
          icon_html = template.capture do
            template.bt_icon options[:icon]
          end
          content = icon_html + " " + content
        end

        css = Button.get_button_class options
        html = get_html_attributes css, options, {
          id: options[:id],
          title: options[:title],
          href: options[:href]
        }
        html[:title] ||= options[:text]
        
        template.content_tag :a, content, html
      end

      def self.get_button_class options
        css = "btn "
        css << Button.get_button_style_class(options[:style])
        css << " " << Button.get_button_size_class(options[:size])
        css
      end

      def self.get_button_style_class style
        "btn-#{ style }"
      end

      def self.get_button_size_class size
        case size
          when :large
            "btn-lg"
          when :small
            "btn-sm"
          when :xsmall
            "btn-xs"
          else
            ""
        end
      end

    end
  end
end