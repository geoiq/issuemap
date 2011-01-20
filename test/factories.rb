Factory.define :map do |m|
  m.title                "Title"
  m.original_csv_data    "a,b,c\n1,2,3"
  m.location_column_name "a"
  m.location_column_type "st"
  m.data_column_name     "b"
  m.data_column_type     "integer"
end
