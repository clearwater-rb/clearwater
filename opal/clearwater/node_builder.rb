class NodeBuilder

  class ClassNameBuilder
    def initialize(attributes)
      @attributes = attributes
    end

    def <<(class_name)
      if @attributes[:class_name].nil?
        @attributes[:class_name] = class_name
      else
        @attributes[:class_name] = @attributes[:class_name] + ' ' + class_name
      end
      self
    end
  end

  def initialize(tag_name, attributes, content)
    @tag_name   = tag_name
    @attributes = attributes
    @content    = content
    @class_list = ClassNameBuilder.new(attributes)
  end

  def class_list
    @class_list
  end

  def style
    @attributes[:style] ||= {}
  end

  def <<(node)
    @content << node
  end

  # HTML Attributes
  %w{
    accept acceptCharset accessKey action allowFullScreen allowTransparency alt
    async autoComplete autoFocus autoPlay capture cellPadding cellSpacing challenge
    charSet checked cite classID className colSpan cols content contentEditable
    contextMenu controls coords crossOrigin data dateTime default defer dir
    disabled download draggable encType form formAction formEncType formMethod
    formNoValidate formTarget frameBorder headers height hidden high href hrefLang
    htmlFor httpEquiv icon id inputMode integrity is keyParams keyType kind label
    lang list loop low manifest marginHeight marginWidth max maxLength media
    mediaGroup method min minLength multiple muted name noValidate nonce open
    optimum pattern placeholder poster preload profile radioGroup readOnly rel
    required reversed role rowSpan rows sandbox scope scoped scrolling seamless
    selected shape size sizes span spellCheck src srcDoc srcLang srcSet start step
    summary tabIndex target title type useMap value width wmode wrap
  }.each { |name|
    define_method("#{name}=") { |value| @attributes[name] = value }
    define_method("#{name}") { @attributes[name] }
  }

  # SVG Attributes
  %w{
    accentHeight accumulate additive alignmentBaseline allowReorder alphabetic
    amplitude arabicForm ascent attributeName attributeType autoReverse azimuth
    baseFrequency baseProfile baselineShift bbox begin bias by calcMode capHeight
    clip clipPath clipPathUnits clipRule colorInterpolation
    colorInterpolationFilters colorProfile colorRendering contentScriptType
    contentStyleType cursor cx cy d decelerate descent diffuseConstant direction
    display divisor dominantBaseline dur dx dy edgeMode elevation enableBackground
    end exponent externalResourcesRequired fill fillOpacity fillRule filter
    filterRes filterUnits floodColor floodOpacity focusable fontFamily fontSize
    fontSizeAdjust fontStretch fontStyle fontVariant fontWeight format from fx fy
    g1 g2 glyphName glyphOrientationHorizontal glyphOrientationVertical glyphRef
    gradientTransform gradientUnits hanging horizAdvX horizOriginX ideographic
    imageRendering in in2 intercept k k1 k2 k3 k4 kernelMatrix kernelUnitLength
    kerning keyPoints keySplines keyTimes lengthAdjust letterSpacing lightingColor
    limitingConeAngle local markerEnd markerHeight markerMid markerStart
    markerUnits markerWidth mask maskContentUnits maskUnits mathematical mode
    numOctaves offset opacity operator order orient orientation origin overflow
    overlinePosition overlineThickness paintOrder panose1 pathLength
    patternContentUnits patternTransform patternUnits pointerEvents points
    pointsAtX pointsAtY pointsAtZ preserveAlpha preserveAspectRatio primitiveUnits
    r radius refX refY renderingIntent repeatCount repeatDur requiredExtensions
    requiredFeatures restart result rotate rx ry scale seed shapeRendering slope
    spacing specularConstant specularExponent speed spreadMethod startOffset
    stdDeviation stemh stemv stitchTiles stopColor stopOpacity
    strikethroughPosition strikethroughThickness string stroke strokeDasharray
    strokeDashoffset strokeLinecap strokeLinejoin strokeMiterlimit strokeOpacity
    strokeWidth surfaceScale systemLanguage tableValues targetX targetY textAnchor
    textDecoration textLength textRendering to transform u1 u2 underlinePosition
    underlineThickness unicode unicodeBidi unicodeRange unitsPerEm vAlphabetic
    vHanging vIdeographic vMathematical values vectorEffect version vertAdvY
    vertOriginX vertOriginY viewBox viewTarget visibility widths wordSpacing
    writingMode x x1 x2 xChannelSelector xHeight xlinkActuate xlinkArcrole
    xlinkHref xlinkRole xlinkShow xlinkTitle xlinkType xmlBase xmlLang xmlSpace
    y y1 y2 yChannelSelector z zoomAndPan
  }.each { |name|
    define_method("#{name}=") { |value| @attributes[name] = value }
    define_method("#{name}") { @attributes[name] }
  }

  # Standard events
  %w{
    oncopy oncut onpaste
    oncompositionend oncompositionstart oncompositionupdate
    onkeydown onkeypress onkeyup
    onfocus onblur
    onchange oninput onsubmit
    onclick oncontextmenu ondoubleclick ondrag ondragend ondragenter ondragexit
    ondragleave ondragover ondragstart ondrop onmousedown onmouseenter onmouseleave
    onmousemove onmouseout onmouseover onmouseup
    onselect
    ontouchcancel ontouchend ontouchmove ontouchstart
    onscroll
    onwheel
    onabort oncanplay oncanplaythrough ondurationchange onemptied onencrypted
    onended onerror onloadeddata onloadedmetadata onloadstart onpause onplay
    onplaying onprogress onratechange onseeked onseeking onstalled onsuspend
    ontimeUpdate onvolumechange onwaiting
    onload onerror
    onanimationstart onanimationend onanimationiteration
    ontransitionend
  }.each { |name|
    define_method("#{name}") { |&block| @attributes[name] = block }
  }

end