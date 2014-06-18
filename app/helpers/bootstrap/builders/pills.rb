module Bootstrap
  module Builders
    class Pills < Base

      def pill options = {}, &block
        content = options[:text] || capture_content
        if (options[:icon])
          icon_html = template.bt_icon options[:icon]
          content = icon_html + " " + content
        end
        link_options = options[:link] || {}
        html = get_html_attributes "", options, { }
        link_html = get_html_attributes "", link_options, { 
          href: options[:href] || "javascript:"
        }
        template.content_tag :li, html do
          template.content_tag :a, content, link_html
        end
      end

      def render
        css = "nav nav-pills"
        css += " nav-stacked" if options[:orientation] == :vertical
        html = get_html_attributes css, options, { }
        template.content_tag :ul, capture_content, html
      end
      
    end
  end
end