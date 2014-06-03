module Bootstrap
  module Builders
    class Form < Base

      def initialize template, options = {}, &block
        initialize_model options
        super template, options, &block
      end

      def render
        html = options[:html] || {}
        html[:id] ||= options[:id] || ""
        html[:class] ||= "form-horizontal"

        template.content_tag :form, capture_content, html
      end

      def group options = {}, &block
        builder = FormGroup.new template, self.options.merge(options), &block
        builder.render
      end

      def text_input options = {}
        property_name = options[:property] || @property_name
        
        html = options[:html] || {}
        data = options[:data] || {}
        data.merge! validation_attributes(property_name)

        data.each do |k, v|
          html["data-" + k.to_s] = v
        end
        html[:id] ||= options[:id] || @element_id || generate_element_id(property_name)
        html[:name] ||= options[:name] || @element_name || generate_full_name(property_name)
        html[:class] ||= "form-control"
        html[:type] = "text"

        template.content_tag :input, "", html
      end

      def hidden_input options = {} 
        property_name = options[:property] || @property_name
        
        html = options[:html] || {}
        data = options[:data] || {}
        data.merge! validation_attributes(property_name)

        data.each do |k, v|
          html["data-" + k.to_s] = v
        end
        html[:id] ||= options[:id] || @element_id || generate_element_id(property_name)
        html[:name] ||= options[:name] || @element_name || generate_full_name(property_name)
        html[:type] = "hidden"

        template.content_tag :input, "", html
      end

      protected

      def initialize_model options
        raise ArgumentError, "Option required: record" unless options[:record]
        case options[:record]
          when String, Symbol
            @model_name = options[:record]
            @model_class = Kernel.const_get(options[:record].capitalize)
            @model = @model_class.new
          else
            @model = options[:record].is_a?(Array) ? options[:record].last : options[:record]
            raise ArgumentError, "First argument in form cannot contain nil or be empty" unless @model
            @model_name  = options[:as] || @model.class.model_name.param_key
            @model_class = @model.class
        end

        # @property_name = nil
        # @element_id = nil
      end

      def validation_attributes property
        attrs = { val: "true" }
        errors = ActiveModel::Errors.new model
        model_class.validators.each do |validator| 
          next unless validator.attributes.include? property
          case validator
          when ActiveModel::Validations::PresenceValidator
            attrs[:'val-required'] = errors.generate_message(property, :blank)
          end
        end
        attrs
      end

      def model
        @model
      end

      def model_name
        @model_name
      end

      def model_class
        @model_class
      end

      def generate_element_id property_name
        raise ArgumentError, "Property name cannot be null" unless property_name
        model_name.to_s + "_" + property_name.to_s
      end

      def generate_full_name property_name
        raise ArgumentError, "Property name cannot be null" unless property_name
        model_name.to_s + "[" + property_name.to_s + "]"
      end
    end

    class FormGroup < Form

      def initialize template, options = {}, &block
        initialize_model options
        raise ArgumentError, "Option required: property" unless options[:property]

        @label_col_size = options[:label_col_size] || 2
        @control_col_size = options[:controls_col_size] || 4
        @property_name = options[:property] || ""
        @element_name = options[:input_name] || generate_full_name(@property_name)
        @element_id = options[:input_id] || generate_element_id(@property_name)
        super template, options, &block
      end

      def render
        label_size = @label_col_size
        ctrl_size = @control_col_size
        content = capture_content
        
        template.capture do
          template.content_tag :div, class: "form-group" do
            html = template.content_tag(:label, options[:label], class: "col-sm-#{label_size} control-label", for: @element_id)
            html << template.content_tag(:div, content, class: "col-sm-#{ctrl_size}")
          end
        end
      end

    end

  end
end