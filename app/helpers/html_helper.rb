module HtmlHelper
  def link_with_icon text, icon, url, html = nil
    html ||= {}
    html[:title] ||= text
    body = bt_icon(icon) + " " + text
    link_to body, url, html
  end

  def validation_errors model
    render partial: 'shared/validation_errors', locals: { model: model }
  end

  def page_header text, options = nil
    options ||= {}
    options[:type] ||= :big
    if (options[:type] == :big)
      render partial: 'shared/page_header_big', locals: { text: text }
    elsif (options[:type] == :small)
      render partial: 'shared/page_header_small', locals: { text: text }
    end
  end

end
