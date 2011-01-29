# Ripped directly from lovely-layouts plugin, then modified for Rails 3
# See: https://github.com/justinfrench/lovely-layouts
#
# TODO: Contribute back to lovely-layouts
module ContentHelper


  def title(string)
    content_for(:title, string)
  end

  def title_tag(*args)
    options = args.extract_options!
    middle = content_value(:title, args.first)
    content_tag(:title, "#{options[:prefix]}#{middle}#{options[:suffix]}")
  end

  def description(string)
    content_for(:description, string)
  end

  def description_tag(default='')
    content = content_value(:description, default)
    tag(:meta, :name => "description", :content => content) unless content.blank?
  end


  def keywords(string)
    content_for(:keywords, string)
  end

  def keywords_tag(default='')
    content = content_value(:keywords, default)
    tag(:meta, :name => "keywords", :content => content) unless content.blank?
  end


  def copyright(string)
    content_for(:copyright, string)
  end

  def copyright_tag(default='')
    content = content_value(:copyright, default)
    tag(:meta, :name => "copyright", :content => content) unless content.blank?
  end


  def body_id(string)
    content_for(:body_id, string)
  end

  def body_class(string)
    content_for(:body_class, string)
  end


  def body(*args, &block)
    options = args.extract_options!
    options[:class] ||= content_value(:body_class, default_body_class)
    options[:id] ||= content_value(:body_id, default_body_id)
    content_tag(:body, options, &block)
  end


  protected

  def content_value(name, alternative = nil)
    content_for?(name) ? content_for(name) : alternative
  end

  def default_body_id
    params[:controller].gsub('/','_')
  end

  def default_body_class
    [params[:controller], params[:action]].join(" ").gsub('/','_')
  end


end
