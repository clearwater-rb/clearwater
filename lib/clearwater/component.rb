require 'clearwater/component/html_tags'
require 'clearwater/dom_reference'

module Clearwater
  module Component
    extend self

    attr_accessor :outlet
    attr_accessor :router

    def render
    end

    HTML_TAGS.each do |tag_name|
      define_method tag_name do |attributes=nil, content=nil|
        tag(tag_name, attributes, content)
      end
    end

    def tag tag_name, attributes=nil, content=nil
      unless attributes.nil? || attributes.is_a?(Hash)
        content = attributes
        attributes = nil
      end

      Tag.new(tag_name, attributes, content)
    end

    def to_s
      content = Array(render).map do |node|
        html = node.to_s
        html.respond_to?(:html_safe) ? html.html_safe : html
      end

      content.join
    end

    def params
      router.params_for_path(router.current_path)
    end

    def call &block
    end

    class Tag
      def initialize tag_name, attributes=nil, content=nil
        @tag_name = tag_name
        @attributes = sanitize_attributes(attributes)
        @content = content
      end

      def to_html
        html = "<#{@tag_name}"
        if @attributes
          @attributes.each do |attr, value|
            html << " #{attr}=#{value.to_s.inspect}"
          end
        end
        if @content
          html << '>'
          html << sanitize_content(@content)
          html << "</#{@tag_name}>"
        else
          html << '/>'
        end

        html
      end
      alias to_s to_html

      def sanitize_attributes attributes
        return attributes unless attributes.is_a? Hash

        if attributes.key? :class_name or attributes.key? :className
          attributes[:class] ||= attributes.delete(:class_name) || attributes.delete(:className)
        end

        if Hash === attributes[:style]
          attributes[:style] = attributes[:style].map { |attr, value|
            attr = attr.to_s.tr('_', '-')
            "#{attr}:#{value}"
          }.join(';')
        end

        attributes.reject! do |key, handler|
          key[0, 2] == 'on' || DOMReference === handler
        end

        attributes
      end

      def sanitize_content content
        case content
        when Array
          content.map { |c| sanitize_content c }.join
        when String
          content.gsub('<', '&lt;')
        else
          content.to_s
        end
      end
    end
  end
end
