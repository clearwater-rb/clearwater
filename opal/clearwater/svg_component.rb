require 'clearwater/component'
require 'clearwater/virtual_dom'

module Clearwater
  module SVGComponent
    def render
    end

    SVG_TAGS = {
      a: 'a',
      alt_glyph: 'altGlyph',
      alt_glyph_def: 'altGlyphDef',
      alt_glyph_item: 'altGlyphItem',
      animate: 'animate',
      animate_color: 'animateColor',
      animate_motion: 'animateMotion',
      animate_transform: 'animateTransform',
      circle: 'circle',
      clip_path: 'clipPath',
      color_profile: 'color-profile',
      cursor: 'cursor',
      defs: 'defs',
      desc: 'desc',
      ellipse: 'ellipse',
      fe_blend: 'feBlend',
      fe_color_matrix: 'feColorMatrix',
      fe_component_transfer: 'feComponentTransfer',
      fe_composite: 'feComposite',
      fe_convolve_matrix: 'feConvolveMatrix',
      fe_diffuse_lighting: 'feDiffuseLighting',
      fe_displacement_map: 'feDisplacementMap',
      fe_distant_light: 'feDistantLight',
      fe_flood: 'feFlood',
      fe_func_a: 'feFuncA',
      fe_func_b: 'feFuncB',
      fe_func_g: 'feFuncG',
      fe_func_r: 'feFuncR',
      fe_gaussian_blur: 'feGaussianBlur',
      fe_image: 'feImage',
      fe_merge: 'feMerge',
      fe_merge_node: 'feMergeNode',
      fe_morphology: 'feMorphology',
      fe_offset: 'feOffset',
      fe_point_light: 'fePointLight',
      fe_specular_lighting: 'feSpecularLighting',
      fe_spot_light: 'feSpotLight',
      fe_tile: 'feTile',
      fe_turbulence: 'feTurbulence',
      filter: 'filter',
      font: 'font',
      font_face: 'font-face',
      font_face_format: 'font-face-format',
      font_face_name: 'font-face-name',
      font_face_src: 'font-face-src',
      font_face_uri: 'font-face-uri',
      foreign_object: 'foreignObject',
      g: 'g',
      glyph: 'glyph',
      glyph_ref: 'glyphRef',
      hkern: 'hkern',
      image: 'image',
      line: 'line',
      linear_gradient: 'linearGradient',
      marker: 'marker',
      mask: 'mask',
      metadata: 'metadata',
      missing_glyph: 'missing-glyph',
      mpath: 'mpath',
      path: 'path',
      pattern: 'pattern',
      polygon: 'polygon',
      polyline: 'polyline',
      radial_gradient: 'radialGradient',
      rect: 'rect',
      script: 'script',
      set: 'set',
      stop: 'stop',
      style: 'style',
      svg: 'svg',
      switch: 'switch',
      symbol: 'symbol',
      text: 'text',
      text_path: 'textPath',
      title: 'title',
      tref: 'tref',
      tspan: 'tspan',
      use: 'use',
      view: 'view',
      vkern: 'vkern',
    }

    SVG_TAGS.each do |method_name, tag_name|
      define_method(method_name) do |attributes, content|
        tag(tag_name, attributes, content)
      end
    end

    def tag tag_name, attributes=nil, content=nil
      if !(`attributes.$$is_hash || attributes === #{nil}`)
        content = attributes
        attributes = nil
      end

      VirtualDOM.svg(
        tag_name,
        Component.sanitize_attributes(attributes),
        Component.sanitize_content(content),
      )
    end
  end
end
