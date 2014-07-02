module Bootstrap
  module Builders
    class Modal < Base

      def initialize template, options = {}, &block
        super template, options, &block

        header do
          template.concat(template.link_to("×", "#",class: 'close', data: { dismiss: 'modal'}))
          
          template.concat(template.content_tag(:h4, options[:header], class: "modal-title"))
        end if options[:header]
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
        
        html = get_html_attributes "modal fade", options, {
          id: options[:id]
        }

        modal_dialog_css = "modal-dialog" 
        case options[:size]
        when :large
          modal_dialog_css << " modal-lg"
        when :small
          modal_dialog_css << " modal-sm"
        end

        template.content_tag :div, html do
          template.content_tag :div, class: modal_dialog_css do
            template.content_tag :div, class: "modal-content" do
              html = ActiveSupport::SafeBuffer.new()
              html << template.content_tag(:div, @header_html, class: "modal-header") unless @header_html.empty?
              html << template.content_tag(:div, @body_html, class: "modal-body") unless @body_html.empty?
              html << template.content_tag(:div, @footer_html, class: "modal-footer") unless @footer_html.empty?
              html
            end
          end
        end
      end
    end
  end
end