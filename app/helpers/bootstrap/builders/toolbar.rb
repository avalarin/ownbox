module Bootstrap
  module Builders
    class Toolbar < Base

      def render
        template.content_tag(:div, captured_content, class: "btn-toolbar")
      end

    end
  end
end