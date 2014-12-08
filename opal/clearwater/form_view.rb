require 'clearwater/view'

module Clearwater
  class FormView < View
    def initialize options={}
      super

      @model = options[:model]
    end

    def form_input field, element=self.element
      element.find("##{field}").value
    end

    def label attribute, text=attribute.capitalize
      "<label for='#{attribute}'>#{text}</label>"
    end

    def text_field attribute, options={}
      value = @model.public_send(attribute) if @model
      params = {
        type: :text,
        id: attribute,
        name: attribute,
        value: value,
      }.merge(options)
      input params
    end

    def email_field attribute, options={}
      text_field attribute, options.merge(type: :email)
    end

    def password_field attribute, options={}
      text_field attribute, options.merge(type: :password)
    end

    def input options={}
      options = options.merge(
        class: "#{options[:class]} attribute"
      )
      "<input #{html_attributes(options)} />"
    end

    def text_area attribute,
                  value=(@model.public_send(attribute) if @model),
                  options={}
      options = options.merge(
        id: attribute,
        name: attribute,
        class: "#{options[:class]} attribute"
      )
      "<textarea #{html_attributes(options)}>#{value}</textarea>"
    end

    def html_attributes options
      options.map { |attr, value| " #{attr}=#{value.to_s.inspect}" }.join
    end
  end
end
