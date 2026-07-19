require "test_helper"

class ChartsHelperTest < ActionView::TestCase
  test "returns an empty string for blank contributions" do
    assert_equal "", contributions_line_chart(nil)
    assert_equal "", contributions_line_chart([])
  end

  test "renders an accessible SVG line chart" do
    html = contributions_line_chart(sample_contributions)

    assert_includes html, "<svg"
    assert_includes html, %(aria-label="GitHub contributions over the past year")
    assert_includes html, "contributions-chart"
    # A line path and a gradient fill path are both drawn.
    assert_equal 2, html.scan("<path").length
    assert_includes html, "url(#chart-gradient)"
  end

  test "emits hover targets carrying date and count data" do
    html = contributions_line_chart(sample_contributions)

    assert_includes html, "hover-targets"
    assert_includes html, %(data-contributions-chart-target="point")
    assert_includes html, %(data-contributions-chart-target="tooltip")
    # Dates are humanized for the tooltip.
    assert_includes html, "January 01, 2026"
  end

  test "produces a numeric path with no NaN coordinates for a normal series" do
    html = contributions_line_chart(sample_contributions)

    refute_includes html, "NaN"
  end

  test "handles a flat (all-zero) series without dividing by zero" do
    flat = (1..10).map { |n| { date: Date.new(2026, 1, n), count: 0 } }

    html = contributions_line_chart(flat)

    assert_includes html, "<svg"
    refute_includes html, "NaN"
  end

  private

  def sample_contributions
    (1..14).map do |n|
      { date: Date.new(2026, 1, n), count: (n * 3) % 7 }
    end
  end
end
