module MapStyles
  STYLE_JSON = <<-JSON
    [{"type": "CHOROPLETH", "stroke": {"alpha": 1, "weight": 2, "color": 14343142}, "fill": {"opacity":0.75, "classificationType": "Equal Interval", "categories": 5, "colors": [14343142, 11580379, 7505585, 4481915, 2966850], "classificationNumClasses": 5}},
    {"type": "CHOROPLETH", "stroke": {"alpha": 1, "weight": 2, "color": 16777164}, "fill": {"opacity": 0.75, "classificationType": "Equal Interval", "categories": 5, "colors": [16777164, 12773017, 7915129, 3253076, 26679], "classificationNumClasses": 5}},
    {"type": "CHOROPLETH", "stroke": {"alpha": 1, "weight": 2, "color": 15456706}, "fill": {"opacity": 0.75, "classificationType": "Equal Interval", "categories": 5, "colors": [15456706, 13744031, 10782317, 8151635, 4863020], "classificationNumClasses": 5}},
    {"type": "CHOROPLETH", "stroke": {"alpha": 1, "weight": 2, "color": 16250871}, "fill": {"opacity": 0.75, "classificationType": "Equal Interval", "categories": 5, "colors":  [16250871, 13421772, 9868950, 6513507, 2434341], "classificationNumClasses": 5}}]
JSON

  def self.included(base)
    @@map_styles ||= JSON.parse(STYLE_JSON)
    base.class_eval do
      cattr_accessor :map_styles
    end
  end
end
