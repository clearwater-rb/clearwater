require 'clearwater/virtual_dom'
require 'browser'

module Clearwater
  module Component
    attr_accessor :router, :outlet

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
      webview
    )

    HTML_TAGS.each do |tag_name|
      define_method(tag_name) do |attributes, content|
        tag(tag_name, attributes, content)
      end
    end

    def tag tag_name, attributes=nil, content=nil
      if !(`attributes.$$is_hash || attributes === #{nil}`)
        content = attributes
        attributes = nil
      end

      VirtualDOM.node(
        tag_name,
        sanitize_attributes(attributes),
        sanitize_content(content)
      )
    end

    def params
      router.params_for_path(router.current_path)
    end

    def sanitize_attributes attributes
      return attributes unless attributes.is_a? Hash

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
        if key[0, 2] == 'on'
          attributes[key] = proc do |event|
            handler.call(Browser::Event.new(event))
          end
        end
      end

      attributes
    end

    def sanitize_content content
      %x{
        if(content && content.$$class) {
          if(content.$$class === Opal.Array) {
            return #{content.map { |c| `self.$sanitize_content(c)` }};
          } else if(content === Opal.nil) {
            return '';
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

    def call &block
      Clearwater::Application::AppRegistry.render_all(&block)
    end
  end
end
