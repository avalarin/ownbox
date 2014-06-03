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

        css = "btn btn-#{ options[:style] }"
        case options[:size] 
          when :large
            css += " btn-lg"
          when :small
            css += " btn-sm"
          when :xsmall
            css += " btn-xs"
        end
        html = get_html_attributes css, [ :title, :href ], options
        html[:title] ||= options[:text]
        
        template.content_tag :a, content, html
      end

    end
  end
end