require 'clearwater/virtual_dom'
require 'set'

module Clearwater
  module Component
    attr_accessor :router, :outlet

    def self.included(klass)
      def klass.attributes(*attrs)
        attrs.each do |attr|
          ivar = "@#{attr}"
          define_method(attr) { instance_variable_get(ivar) }
          define_method("#{attr}=") do |value|
            instance_variable_set ivar, value
            call
          end
        end
      end
    end

    def render
    end

    HTML_TAGS = %w(
      a
      abbr
      address
      area
      article
      aside
      audio
      b
      base
      bdi
      bdo
      blockquote
      body
      br
      button
      canvas
      caption
      cite
      code
      col
      colgroup
      command
      data
      datalist
      dd
      del
      details
      dfn
      dialog
      div
      dl
      dt
      em
      embed
      fieldset
      figcaption
      figure
      footer
      form
      h1
      h2
      h3
      h4
      h5
      h6
      head
      header
      hgroup
      hr
      html
      i
      iframe
      img
      input
      ins
      kbd
      keygen
      label
      legend
      li
      link
      map
      mark
      menu
      meta
      meter
      nav
      noscript
      object
      ol
      optgroup
      option
      output
      p
      param
      pre
      progress
      q
      rp
      rt
      ruby
      s
      samp
      script
      section
      select
      small
      source
      span
      strong
      style
      sub
      summary
      sup
      table
      tbody
      td
      textarea
      tfoot
      th
      thead
      time
      title
      tr
      track
      u
      ul
      var
      video
      wbr
    )

    HTML_TAGS.each do |tag|
      define_method(tag) do |*args|
        tag(tag, *args)
      end
    end

    def tag tag_name, attributes=nil, content=nil
      VirtualDOM.node(
        tag_name,
        sanitize_attributes(attributes),
        sanitize_content(content)
      )
    end

    def params
      router.params_for_path(router.current_path)
    end

    def param(key)
      params[key]
    end

    def sanitize_attributes attributes
      return nil if attributes.nil?

      # Allow specifying `class` instead of `class_name`.
      # Note: `class_name` is still allowed
      if attributes.key? :class
        if attributes.key? :class_name
          warn "You have both `class` and `class_name` attributes for this " +
            "element. `class` takes precedence: #{attributes}"
        end

        attributes[:class_name] = attributes.delete(:class)
      end

      attributes.each do |key, handler|
        if key.start_with? 'on'
          attributes[key] = proc do |event|
            handler.call(Browser::Event.new(event))
          end
        end
      end

      attributes
    end

    def sanitize_content content
      case content
      when Numeric, String
        content.to_s
      when Array
        content.map { |c| sanitize_content(c) }.compact
      else
        if content.respond_to? :cached_render
          content.cached_render
        elsif content.respond_to? :render
          sanitize_content content.render
        else
          content
        end
      end
    end

    def call
      Clearwater::Application::AppRegistry.render_all
    end
  end
end
