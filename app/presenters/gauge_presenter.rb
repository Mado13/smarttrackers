class GaugePresenter
  def initialize(gauge)
    @gauge = gauge
  end

  def date_range
    "#{format_date(@gauge.start_date)} - #{format_date(@gauge.end_date)}"
  end

  private

  def format_date(date)
    date.strftime('%-d %b %Y')
  end
end
