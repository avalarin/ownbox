module Bootstrap
  module Builders
    class Modal < Base

      def initialize template, options = {}, &block
        super template, options, &block

        header do
          template.concat(template.link_to("×", "#",class: 'close', data: { dismiss: 'modal'}))
          
          template.concat(template.content_tag(:h3, options[:header]))
        end
      end

      def header &block
        @header_html = template.capture &block
      end
      
      def body &block
        @body_html = template.capture &block
      end
      
      def footer &block
        @footer_html = template.capture &block
      end

      def render
        capture_content
        
        @header_html ||= ""
        @body_html ||= ""
        @footer_html ||= ""
        
        html = get_html_attributes "modal fade", [ :id ], options

        template.content_tag :div, html do
          template.content_tag :div, class: "modal-dialog" do
            template.content_tag :div, class: "modal-content" do
              html =  template.content_tag(:div, @header_html, class: "modal-header")
              html << template.content_tag(:div, @body_html, class: "modal-body")
              html << template.content_tag(:div, @footer_html, class: "modal-footer")
              html
            end
          end
        end
      end
    end
  end
end