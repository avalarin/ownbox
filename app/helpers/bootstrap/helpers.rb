require File.expand_path('../builders/modal.rb', __FILE__)
require File.expand_path('../builders/panel.rb', __FILE__)

module Bootstrap
  module Helpers
    def bt_modal(options = {}, &block)
      builder = ::Bootstrap::Builders::Modal.new(self, options, &block)
      builder.render
    end

    def bt_panel options = {}, &block
      builder = ::Bootstrap::Builders::Panel.new(self, options, &block)
      builder.render
    end

    def bt_toolbar options = {}, &block
      builder = ::Bootstrap::Builders::Toolbar.new(self, options, &block)
      builder.render
    end

    def bt_button options = {}, &block
      builder = ::Bootstrap::Builders::Button.new(self, options, &block)
      builder.render
    end

    def bt_icon name, options = {}, &block
      options[:name] = name
      builder = ::Bootstrap::Builders::Icon.new(self, options, &block)
      builder.render
    end

    def bt_form_for record, options = {}, &block
      options[:record] = record
      builder = ::Bootstrap::Builders::Form.new(self, options, &block)
      builder.render
    end

    def bt_label text, options = {}, &block
      options[:text] = text
      builder = ::Bootstrap::Builders::Label.new(self, options, &block)
      builder.render
    end

    def bt_pills options = {}, &block
      builder = ::Bootstrap::Builders::Pills.new(self, options, &block)
      builder.render
    end

  end
end