module MapsHelper
  def fieldset_error_messages(object, *methods)
    messages = methods.map do |method|
      error_message  = object.errors[method]
      error_sentence = [object.class.human_attribute_name(method), error_message].join(" ")
      content_tag(:div, error_sentence) if error_message.present?
    end.join
    content_tag(:div, messages, :class => "error-message")
  end

  def fieldset_errored?(object, *methods)
    methods.any? { |method| object.errors[method].present? }
  end

  def fieldset_completed?(object, *methods)
    methods.all? { |method| object.errors[method].blank? && object.send(method).present? }
  end

  def fieldset_style_classes(object, *methods)
    errored   = "errored"   if fieldset_errored?(object, *methods)
    completed = "completed" if fieldset_completed?(object, *methods)
    [errored, completed].compact.join(" ")
  end

  def completable_fieldset(object, *methods, &block)
    options = methods.extract_options!
    style_class = options.delete(:class)
    additional_classes = fieldset_style_classes(object, *methods)
    content = fieldset_error_messages(object, *methods)
    content << capture(&block)
    content_tag(:fieldset, content, options.merge(:class => "#{style_class} #{additional_classes}"))
  end

  def compact_embed_code(map, locals = {})
    embed_code = render :partial => "maps/embed", :locals => locals.merge(:map => map)
    CGI::unescape_html(embed_code.lines.map(&:strip).join)
  end

  def location_type_options
    [["Please select a location type...", nil]] + AppConfig[:boundaries]
  end

  def data_type_options
    [["Please select a data type...", nil]] + DATA_TYPES
  end

  DATA_TYPES = [['Plain text', 'string'],
                ['Whole numbers', 'integer'],
                ['Decimals', 'decimal'],
                ['Time or Date', 'datetime']]

  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF.html_safe
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{h(text)}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{h(text)}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end

  def map_admin?(map)
    session[:owned_maps].include?(map.id) if session[:owned_maps]
  end

  def map_admin_section(map, &block)
    capture(&block) if map_admin?(map)
  end
end
