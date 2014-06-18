module Bootstrap
  module Builders
    class Label < Base

      def render
        options[:style] ||= :default
        css = "label btn-#{ options[:style] }"
        html = get_html_attributes css, options, {
          id: options[:id]
        }
        template.content_tag :span, options[:text], html 
      end


    end
  end
end