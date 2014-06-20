module Bootstrap
  module Builders
    class Form < Base

      def initialize template, options = {}, &block
        initialize_model options
        super template, options, &block
      end

      def render
        method = options[:method] || :post
        original_method = method
        if (method != :get && method != :post)
          method = :post;
        end
        options[:style] ||= :default
        case options[:style]
        when :horizontal
          css = "form-horizontal "
        else
          css = ""
        end

        html = get_html_attributes css, options, {
          id: options[:id],
          action: options[:action],
          method: method
        }

        pre_content = template.content_tag :input, "", {
          type: "hidden",
          value: template.form_authenticity_token,
          name: "authenticity_token"
        }
        pre_content << template.content_tag(:input, "", {
          type: "hidden",
          value: original_method,
          name: "_method"
        })

        template.content_tag :form, pre_content + capture_content, html
      end

      def group options = {}, &block
        builder = FormGroup.new template, self.options.merge(options), &block
        builder.render
      end

      def text_input options = {}
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ""

        html = get_html_attributes "form-control", options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          placeholder: options[:placeholder] || @element_placeholder,
          value: options[:value] || value,
          type: "text"
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :input, "", html
      end

      def hidden_input options = {} 
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ""

        html = get_html_attributes "form-control", options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          value: options[:value] || value,
          type: "hidden"
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :input, "", html
      end

      def password_input options = {}
        property_name = options[:property] || @property_name
        value = model.respond_to?(property_name) ? model.send(property_name) : ""

        html = get_html_attributes "form-control", options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          name: options[:name] || @element_name || generate_full_name(property_name),
          placeholder: options[:placeholder] || @element_placeholder,
          value: options[:value] || value,
          type: "password"
        }
        html.merge! validation_attributes(property_name)

        template.content_tag :input, "", html
      end

      def submit_button options = {}
        property_name = options[:property] || @property_name
        css = Button.get_button_class options
        html = get_html_attributes css, options, {
          id: options[:id] || @element_id || generate_element_id(property_name),
          type: "submit"
        }
        template.content_tag :button, options[:text], html
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
        attrs = { :'data-val' => "true" }
        errors = ActiveModel::Errors.new model
        model_class.validators.each do |validator| 
          next unless validator.attributes.include? property
          validator_options = {}
          validator.options.each_pair { |k, v| validator_options[k] = v }
          case validator
          when ActiveModel::Validations::PresenceValidator
            attrs[:'data-val-required'] = errors.generate_message(property, :blank)
          when ActiveModel::Validations::LengthValidator
            # if validator_options.has_key? :is
            #   attrs[:'data-val-is'] = errors.generate_message(property, :wrong_length)
            # end
            if validator_options.has_key?(:minimum) && validator_options.has_key?(:maximum)
              attrs[:'data-val-length'] = errors.generate_message(property, :too_short_or_too_long_no_count)
              attrs[:'data-val-length-min'] = validator_options[:minimum]
              attrs[:'data-val-length-max'] = validator_options[:maximum]
            end
            if validator_options.has_key? :minimum
              attrs[:'data-val-length'] = errors.generate_message(property, :too_short_no_count, validator_options)
              attrs[:'data-val-length-min'] = validator_options[:minimum]
            end
            if validator_options.has_key? :maximum
              attrs[:'data-val-length'] = errors.generate_message(property, :too_long_no_count, validator_options)
              attrs[:'data-val-length-min'] = 0
              attrs[:'data-val-length-max'] = validator_options[:maximum]
            end
          when EmailFormatValidator
            attrs[:'data-val-regex'] = errors.generate_message(property, :invalid_email_address)
            attrs[:'data-val-regex-pattern'] = "^[^@]+@[^@]+$"
          when ActiveModel::Validations::ConfirmationValidator
            other = property.to_s + "_confirmation"
            attrs[:'data-val-equalto'] = errors.generate_message(property, other.to_sym)
            attrs[:'data-val-equalto-other'] = generate_full_name other
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
        return "" if property_name == "" || !property_name
        model_name.to_s + "_" + property_name.to_s
      end

      def generate_full_name property_name
        return "" if property_name == "" || !property_name
        model_name.to_s + "[" + property_name.to_s + "]"
      end
    end

    class FormGroup < Form

      def initialize template, options = {}, &block
        initialize_model options

        if (options[:label_col_size] && options[:controls_col_size])
          @label_col_size = options[:label_col_size] || 3
          @control_col_size = options[:controls_col_size] || 12
        elsif options[:label_col_size]
          @label_col_size = options[:label_col_size]
          @control_col_size = 12 - @label_col_size
        elsif options[:controls_col_size]
          @control_col_size = options[:controls_col_size]
          @label_col_size = 12 - @control_col_size
        else
          @label_col_size = 3
          @control_col_size = 9
        end
                
        @property_name = options[:property] || ""
        @element_name = options[:input_name] || generate_full_name(@property_name)
        @element_id = options[:input_id] || generate_element_id(@property_name)
        @element_placeholder = options[:label] || ""
        super template, options, &block
      end

      def render
        label_size = @label_col_size
        ctrl_size = @control_col_size
        content = capture_content
        
        template.capture do
          if options[:style] == :horizontal
            label_class = "col-sm-#{label_size} "
            ctrl_class = "col-sm-#{ctrl_size} "
          else
            label_class = ""
            ctrl_class = ""
          end
          template.content_tag(:div, class: "form-group") do
            if options[:label]
              html = template.content_tag(:label, options[:label], class: label_class + "control-label", for: @element_id)
              html << template.content_tag(:div, content, class: ctrl_class)
              html
            else
              content
            end
          end
        end
      end

    end

  end
end