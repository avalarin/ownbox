module HtmlHelper
  def icon name, options = nil
    options ||= {}
    tag_class = "fa fa-#{name} "
    if options[:icon_size] == :large
      tag_class += " fa-lg"
    elsif options[:icon_size] == :x2
      tag_class += " fa-2x"
    elsif options[:icon_size] == :x3
      tag_class += " fa-3x"
    elsif options[:icon_size] == :x4
      tag_class += " fa-4x"
    elsif options[:icon_size] == :x5
      tag_class += " fa-5x"
    end
    "<i class=\"#{tag_class}\"></i>".html_safe
  end

  def link_with_icon text, icon, url, html = nil
    html ||= {}
    html[:title] ||= text
    body = icon(icon) + " " + text;
    link_to body, url, html;
  end

  def validation_errors model
    render partial: 'shared/validation_errors', locals: { model: model }
  end
end
