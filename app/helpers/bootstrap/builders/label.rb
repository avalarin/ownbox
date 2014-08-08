module Bootstrap
  module Builders
    class Label < Base

      def render
        options[:style] ||= :none
        css = ""
        css << "label label-#{ options[:style] }" if options[:style] != :none
        html = get_html_attributes css, options, {
          id: options[:id]
        }
        if options[:icon]
          template.content_tag :span, html do 
            template.bt_icon(options[:icon]) + "\n" + template.content_tag(:span, options[:text]) 
          end
        else
          template.content_tag :span, options[:text], html 
        end
      end


    end
  end
end