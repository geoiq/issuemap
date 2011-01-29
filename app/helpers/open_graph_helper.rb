module OpenGraphHelper
  def og_title(string)
    content_for(:og_title, string)
  end

  def og_title_tag(default = nil)
    content = content_value(:og_og_title, default)
    tag(:meta, :name => "og:title", :content => content) unless content.blank?
  end

  def og_type(string)
    content_for(:og_type, string)
  end

  def og_type_tag(default = nil)
    content = content_value(:og_title, default)
    tag(:meta, :name => "og:type", :content => content) unless content.blank?
  end

  def og_url(string)
    content_for(:og_url, string)
  end

  def og_url_tag(default = nil)
    content = content_value(:og_url, default)
    tag(:meta, :name => "og:url", :content => content) unless content.blank?
  end

  def og_image(string)
    content_for(:og_image, string)
  end

  def og_image_tag(default = nil)
    content = content_value(:og_image, default)
    tag(:meta, :name => "og:image", :content => content) unless content.blank?
  end

  def og_site_name(string)
    content_for(:og_site_name, string)
  end

  def og_site_name_tag(default = nil)
    content = content_value(:og_site_name, default)
    tag(:meta, :name => "og:site_name", :content => content) unless content.blank?
  end

  def og_description(string)
    content_for(:og_description, string)
  end

  def og_description_tag(default = nil)
    content = content_value(:og_description, default)
    tag(:meta, :name => "og:description", :content => content) unless content.blank?
  end

  protected

  def content_value(name, alternative = nil)
    content_for?(name) ? content_for(name) : alternative
  end
end
