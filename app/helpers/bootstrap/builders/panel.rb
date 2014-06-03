module Bootstrap
  module Builders
    class Panel < Base
      def initialize template, options = {}, &block
        @header_html = options[:header]
        @capture_all = true
        super template, options, &block
      end

      def table &block
        @table_html = template.capture &block
        @capture_all = false
      end

      def header &block
        @header_html = template.capture &block
        @capture_all = false
      end

      def body &block
        @body_html = template.capture &block
        @capture_all = false
      end

      def render
        @all_html = capture_content
        @body_html = @all_html if @capture_all
        template.content_tag :div, class: "panel panel-default" do
          template.concat(template.content_tag(:div, @header_html, class: "panel-heading"))
          template.concat(template.content_tag(:div, @body_html, class: "panel-body")) if @body_html
          template.concat(@table_html) if @table_html
        end
      end
    end
  end
end