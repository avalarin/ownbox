module DatatableHelper
  
  def get_table_page_size table_name
    key = (table_name.to_s + "_page_size").to_s
    cookie_value = cookies[key]
    page_size = cookie_value ? [1, cookie_value.to_i].max : Settings.admin.page_size
    if params[:per_page]
      page_size = params[:per_page].to_i
      set_table_page_size table_name, page_size
    end
    page_size
  end

  def set_table_page_size table_name, page_size
    key = (table_name.to_s + "_page_size").to_s
    cookies[key] = page_size
  end

  def filters_list options = {}, filters
    context = options[:context] || 'datatable'
    bt_pills orientation: :vertical, data: { bind: "with: #{context}" } do |pills|
      filters.each_pair do |key, value| 
        concat pills.pill(text: value[:text], icon: value[:icon], 
                      data: { bind: "css: { active: filter() == '#{key}' }" },
                      link: { data: { bind: "click: function() { changeFilter('#{key}') }" } })
      end
    end
  end

  def search_box options = {}
    context = options[:context] || 'datatable'
    placeholder = options[:placeholder] || ''

    content_tag(:div, "class" => "input-group datatable-search", "data-bind" => "with: #{context}") do
      concat(content_tag(:input, "", "class" => "form-control", "type" => "text", 
                          "data-bind" => "value: search", "placeholder" => placeholder))
      concat(content_tag(:span, "class" => "input-group-btn")do
        concat(bt_button(title: t('commands.search'), icon: 'search', data: { bind: 'click: refresh' }))
      end)
    end
  end

end