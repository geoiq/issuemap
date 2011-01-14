class Test::Unit::TestCase
  # assert_form posts_url, :put do
  #   assert_text_field :post, :title
  #   assert_text_area  :post, :body
  #   assert_submit
  # end
  def assert_form(url, http_method = :post, count = 1)
    http_method, hidden_http_method = form_http_method(http_method)
    assert_select "form[action=?][method=#{http_method}]", url, :count => count do
      if hidden_http_method
        assert_select "input[type=hidden][name=_method][value=#{hidden_http_method}]"
      end
      if block_given?
        yield
      end
    end
  end
  def assert_no_form(url, http_method = :post)
    assert_form(url, http_method, 0)
  end

  def form_http_method(http_method)
    http_method = http_method.to_s
    if http_method == "post" || http_method == "get"
      return http_method, nil
    else
      return "post", http_method
    end
  end

  def assert_submit
    assert_select "button[type=submit]"
  end

  # TODO: default to test the label, provide :label => false option
  def assert_text_field(model, *attributes)
    attributes.each do |attribute|
      assert_select "input[type=text][name=?]",
                    "#{model.to_s}[#{attribute.to_s}]"
    end
  end
  alias assert_text_fields assert_text_field

  # TODO: default to test the label, provide :label => false option
  def assert_text_area(model, *attributes)
    attributes.each do |attribute|
      assert_select "textarea[name=?]",
                    "#{model.to_s}[#{attribute.to_s}]"
    end
  end
  alias assert_text_areas assert_text_area

  # TODO: default to test the label, provide :label => false option
  def assert_password_field(model, *attributes)
    attributes.each do |attribute|
      assert_select "input[type=password][name=?]",
                    "#{model.to_s}[#{attribute.to_s}]"
    end
  end
  alias assert_password_fields assert_password_field

  # TODO: default to test the label, provide :label => false option
  def assert_radio_button(model, *attributes)
    attributes.each do |attribute|
      assert_select "input[type=radio][name=?]",
                    "#{model.to_s}[#{attribute.to_s}]"
    end
  end
  alias assert_radio_buttons assert_radio_button

  # TODO: default to test the label, provide :label => false option
  def assert_check_box(model, *attributes)
    attributes.each do |attribute|
      assert_select "input[type=checkbox][name=?]",
                    "#{model.to_s}[#{attribute.to_s}]"
    end
  end
  alias assert_check_boxes assert_check_box

  # TODO: add hidden_field
  # TODO: add file_field

  def assert_label(model, *attributes)
    attributes.each do |attribute|
      label = "#{model.to_s.underscore}_#{model.to_s.underscore}"
      assert_select "label[for=?]", label
    end
  end
  alias assert_labels assert_label
end
