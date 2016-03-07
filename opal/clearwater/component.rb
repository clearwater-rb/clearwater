require 'clearwater/virtual_dom'

module Clearwater
  module Component
    attr_accessor :router, :outlet

    def params
      router.params
    end

    def self.sanitize_attributes attributes
      return attributes unless attributes.is_a? Hash

      attributes.each do |key, value|
        if `key.slice(0, 2)` == 'on'
          attributes[key] = proc do |event|
            value.call(Bowser::Event.new(event))
          end
        end
      end

      # Allow specifying `class` instead of `class_name`.
      # Note: `class_name` is still allowed
      if attributes.key?(:class)
        if attributes.key?(:class_name)
          warn "You have both `class` and `class_name` attributes for this " +
            "element. `class` takes precedence: #{attributes}"
        end

        attributes[:class_name] = attributes.delete :class
      end

      attributes
    end

    def self.sanitize_content content
      %x{
        if(content && content.$$class) {
          if(content.$$is_array) {
            return #{content.map { |c| sanitize_content(c) }};
          } else {
            var render = content.$render;

            if(content.type === 'Thunk' && typeof(content.render) === 'function') {
              return content;
            } else if(render && !render.$$stub) {
              return self.$sanitize_content(content.$render());
            } else {
              return content;
            }
          }
        } else {
          return content;
        }
      }
    end

    # Default render method for stubbing
    def render
    end

    module_function

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
      main
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

    HTML_TAGS.each do |tag_name|
      define_method(tag_name) do |attributes, content|
        %x{
          if(!(attributes === nil || attributes.$$is_hash)) {
            content = attributes;
            attributes = nil;
          }
        }

        tag(tag_name, attributes, content)
      end
    end

    def tag tag_name, attributes=nil, content=nil
      VirtualDOM.node(
        tag_name,
        Component.sanitize_attributes(attributes),
        Component.sanitize_content(content)
      )
    end

    def call &block
      Clearwater::Application::AppRegistry.render_all(&block)
    end
  end
end
