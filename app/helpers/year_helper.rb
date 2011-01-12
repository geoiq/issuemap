module YearHelper
  def current_year
    Time.now.year
  end

  def year_range(start_year = current_year)
    [start_year, current_year].sort.uniq.join('-')
  end
end
