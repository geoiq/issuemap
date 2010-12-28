Factory.define(:map) do |m|
  m.title "Sample Map"
  m.dataset
end

Factory.define(:dataset) do |d|
  d.map
  d.upload File.new(Rails.root.join('lib', 'example.csv'))
end
