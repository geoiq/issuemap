ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  "<span class=\"errored\">#{html_tag}</span>"
}
