module MapsHelper
  def compact_embed_code(map, locals = {})
    embed_code = render :partial => "maps/embed", :locals => locals.merge(:map => map)
    embed_code = embed_code.lines.map(&:strip).join
  end

  def location_type_options
    options_for_select([["Please select a location type...", nil]] + AppConfig[:boundaries])
  end

  def data_type_options
    options_for_select([["Please select a data type...", nil]] + DATA_TYPES)
  end

  DATA_TYPES = [['Plain text', 'string'],
                ['Whole numbers', 'integer'],
                ['Decimals', 'decimal'],
                ['Time or Date', 'datetime']]

  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
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
end
