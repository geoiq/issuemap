module ApplicationHelper
  def render_flash_messages(*keys)
    messages = keys.map do |key|
      content_tag(:p, flash_message_with_item(key), :class => "flash #{key}") if flash[key]
    end.join.html_safe
    content_tag(:div, messages, :id => "flash_messages") unless messages.blank?
  end

  def flash_message_with_item(key)
    item = flash["#{key}_item".to_sym]
    substitution = item.is_a?(Array) ? link_to(*item) : item
    flash[key] % substitution
  end
end
