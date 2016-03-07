require 'clearwater/virtual_dom'

module Clearwater
  module Component
    attr_accessor :router, :outlet

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

    HTML_ATTRIBUTES = {
      accept: 'accept',
      accept_charset: 'acceptCharset',
      access_key: 'accessKey',
      action: 'action',
      allow_full_screen: 'allowFullScreen',
      allow_transparency: 'allowTransparency',
      alt: 'alt',
      async: 'async',
      auto_complete: 'autoComplete',
      auto_focus: 'autoFocus',
      auto_play: 'autoPlay',
      capture: 'capture',
      cell_padding: 'cellPadding',
      cell_spacing: 'cellSpacing',
      challenge: 'challenge',
      char_set: 'charSet',
      checked: 'checked',
      class_id: 'classID',
      class_name: 'className',
      col_span: 'colSpan',
      cols: 'cols',
      content: 'content',
      content_editable: 'contentEditable',
      context_menu: 'contextMenu',
      controls: 'controls',
      coords: 'coords',
      cross_origin: 'crossOrigin',
      data: 'data',
      date_time: 'dateTime',
      default: 'default',
      defer: 'defer',
      dir: 'dir',
      disabled: 'disabled',
      download: 'download',
      draggable: 'draggable',
      enc_type: 'encType',
      form: 'form',
      form_action: 'formAction',
      form_enc_type: 'formEncType',
      form_method: 'formMethod',
      form_no_validate: 'formNoValidate',
      form_target: 'formTarget',
      frame_border: 'frameBorder',
      headers: 'headers',
      height: 'height',
      hidden: 'hidden',
      high: 'high',
      href: 'href',
      href_lang: 'hrefLang',
      html_for: 'htmlFor',
      http_equiv: 'httpEquiv',
      icon: 'icon',
      id: 'id',
      input_mode: 'inputMode',
      integrity: 'integrity',
      is: 'is',
      key_params: 'keyParams',
      key_type: 'keyType',
      kind: 'kind',
      label: 'label',
      lang: 'lang',
      list: 'list',
      loop: 'loop',
      low: 'low',
      manifest: 'manifest',
      margin_height: 'marginHeight',
      margin_width: 'marginWidth',
      max: 'max',
      max_length: 'maxLength',
      media: 'media',
      media_group: 'mediaGroup',
      method: 'method',
      min: 'min',
      min_length: 'minLength',
      multiple: 'multiple',
      muted: 'muted',
      name: 'name',
      no_validate: 'noValidate',
      nonce: 'nonce',
      open: 'open',
      optimum: 'optimum',
      pattern: 'pattern',
      placeholder: 'placeholder',
      poster: 'poster',
      preload: 'preload',
      radio_group: 'radioGroup',
      read_only: 'readOnly',
      rel: 'rel',
      required: 'required',
      reversed: 'reversed',
      row_span: 'rowSpan',
      rows: 'rows',
      sandbox: 'sandbox',
      scope: 'scope',
      scoped: 'scoped',
      scrolling: 'scrolling',
      seamless: 'seamless',
      selected: 'selected',
      shape: 'shape',
      size: 'size',
      sizes: 'sizes',
      span: 'span',
      spell_check: 'spellCheck',
      src: 'src',
      src_doc: 'srcDoc',
      src_lang: 'srcLang',
      src_set: 'srcSet',
      start: 'start',
      step: 'step',
      style: 'style',
      summary: 'summary',
      tab_index: 'tabIndex',
      target: 'target',
      title: 'title',
      type: 'type',
      use_map: 'useMap',
      value: 'value',
      width: 'width',
      wmode: 'wmode',
      wrap: 'wrap',
    }

    def params
      router.params
    end

    def self.sanitize_attributes attributes
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

      memo = {attributes: attributes[:attributes] || {} }
      sanitized = attributes.each_with_object(memo) do |(key, value), hash|
        if svg_attr = HTML_ATTRIBUTES[key]
          hash[svg_attr] = value
        elsif key[0, 2] == 'on'
          hash[key] = proc do |event|
            value.call(Bowser::Event.new(event))
          end
        else
          hash[:attributes][key.gsub('_', '-')] = value
        end
      end

      sanitized
    end

    def self.sanitize_content content
      %x{
        if(content && content.$$class) {
          if(content.$$class === Opal.Array) {
            return #{content.map { |c| `self.$sanitize_content(c)` }};
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
        Component.sanitize_attributes(attributes),
        Component.sanitize_content(content)
      )
    end

    def call &block
      Clearwater::Application::AppRegistry.render_all(&block)
    end
  end
end
