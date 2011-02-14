module MapStyles
  WHITE_PALETTES = {
    :white_orange     => [0xFEF7A5, 0xFECE6D, 0xEC8414, 0xAE4C02, 0x662506],
    :white_dark_green => [0xDADBE6, 0xB0B3DB, 0x7286B1, 0x44637B, 0x2D4542],
    :white_brown      => [0xEBD9C2, 0xd1b79f, 0xA4866D, 0x7C6253, 0x4A342C],
    :white_gray       => [0xF7F7F7, 0xCCCCCC, 0x969696, 0x636363, 0x252525],
    :white_red        => [0xFEE5D9, 0xFCAE91, 0xFB6A4A, 0xDE2D26, 0xA50F15],
    :white_green      => [0xFFFFCC, 0xC2E699, 0x78C679, 0x31A354, 0x006837],
    :white_blue       => [0xEFF3FF, 0xBDD7E7, 0x6BAED6, 0x3182BD, 0x08519C],
    :white_purple     => [0xFCE3D7, 0xE3BBC2, 0xC090BD, 0x835BA4, 0x511483],
  }

  EXTRA_PALETTES = {
    :diverging        => [0x909FC2, 0xD0D1E6, 0xF7F7F7, 0xFEE281, 0xFE9929],
    :green_purple     => [0x78C679, 0xD9F0A3, 0xF7F7F7, 0xE6C7CA, 0xC090BD],
    :blue_red         => [0x4292C6, 0xC6DBEF, 0xF7F7F7, 0xFCC5BB, 0xFF776D],
  }

  COLOR_PALETTES = ActiveSupport::HashWithIndifferentAccess.new(WHITE_PALETTES.merge(EXTRA_PALETTES))

  def self.random_color_palette
    WHITE_PALETTES.keys.sample
  end

  def self.random_choropleth
    choropleth(random_color_palette)
  end

  def self.choropleth(color_palette)
    colors = COLOR_PALETTES[color_palette]
    {
      :type => "CHOROPLETH",
      :fill => {
        :opacity            => 0.75,
        :classificationType => "Equal Interval",
        :categories         => colors.length,
        :colors             => colors,
      }
    }
  end
end
