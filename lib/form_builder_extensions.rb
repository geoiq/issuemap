# Styling an input[type=submit] is futile.  Fancy-buttons recommends using
# button[type=submit] instead, so lets default to that when calling the submit
# form helper.
class ActionView::Helpers::FormBuilder
  def submit(value = "Save changes", options = {})
    @template.content_tag(:button, value, options.reverse_merge(:id => "#{object_name}_submit", :type => "submit"))
  end
end
