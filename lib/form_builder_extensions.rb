# Styling an input[type=submit] is futile.  Fancy-buttons recommends using
# button[type=submit] instead.
class ActionView::Helpers::FormBuilder
  def submit(value = "Save changes", options = {})
    @template.content_tag(:button, value, options.reverse_merge(:id => "#{object_name}_submit", :type => "submit"))
  end
end
