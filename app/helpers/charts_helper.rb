module ChartsHelper
  def contributions_line_chart(contributions)
    return "" if contributions.blank?

    width = 800
    height = 60
    padding_x = 2
    padding_y = 8

    chart_width = width - (padding_x * 2)
    chart_height = height - (padding_y * 2)

    max_count = contributions.map { |c| c[:count] }.max || 1
    max_count = [max_count, 1].max # Avoid division by zero

    # Calculate points
    points = contributions.each_with_index.map do |contribution, index|
      x = padding_x + (index.to_f / (contributions.length - 1)) * chart_width
      y = padding_y + chart_height - (contribution[:count].to_f / max_count) * chart_height
      { x: x, y: y, date: contribution[:date], count: contribution[:count] }
    end

    # Generate smooth bezier path
    path_d = generate_smooth_path(points)
    fill_path_d = generate_fill_path(points, height, padding_y, chart_height)

    # Build SVG
    content_tag(:div, class: "contributions-chart relative") do
      svg = content_tag(:svg,
        viewBox: "0 0 #{width} #{height}",
        class: "w-full h-16 md:h-20",
        preserveAspectRatio: "none",
        "aria-label": "GitHub contributions over the past year"
      ) do
        safe_join([
          # Gradient definition
          content_tag(:defs) do
            content_tag(:linearGradient, id: "chart-gradient", x1: "0%", y1: "0%", x2: "0%", y2: "100%") do
              safe_join([
                tag(:stop, offset: "0%", "stop-color": "var(--color-forest)", "stop-opacity": "0.15"),
                tag(:stop, offset: "100%", "stop-color": "var(--color-forest)", "stop-opacity": "0")
              ])
            end
          end,

          # Fill area
          tag(:path,
            d: fill_path_d,
            fill: "url(#chart-gradient)"
          ),

          # Line
          tag(:path,
            d: path_d,
            fill: "none",
            stroke: "var(--color-forest)",
            "stroke-width": "1.5",
            "stroke-linecap": "round",
            "stroke-linejoin": "round"
          ),

          # Invisible hover targets (grouped for easier interaction)
          content_tag(:g, class: "hover-targets") do
            safe_join(
              points.each_with_index.map do |point, index|
                # Only render every 7th point for weekly granularity (reduces DOM size)
                next unless (index % 7).zero? || index == points.length - 1

                content_tag(:circle,
                  "",
                  cx: point[:x],
                  cy: point[:y],
                  r: 8,
                  fill: "transparent",
                  class: "cursor-pointer",
                  data: {
                    contributions_chart_target: "point",
                    date: point[:date].strftime("%B %d, %Y"),
                    count: point[:count]
                  }
                )
              end.compact
            )
          end
        ])
      end

      tooltip = content_tag(:div,
        "",
        class: "absolute hidden bg-ink text-cream text-xs px-2 py-1 rounded pointer-events-none whitespace-nowrap z-10",
        data: { contributions_chart_target: "tooltip" }
      )

      safe_join([svg, tooltip])
    end
  end

  private

  def generate_smooth_path(points)
    return "" if points.empty?
    return "M #{points[0][:x]} #{points[0][:y]}" if points.length == 1

    path = "M #{points[0][:x]} #{points[0][:y]}"

    # Use Catmull-Rom to Bezier conversion for smooth curves
    points.each_with_index do |_point, i|
      next if i.zero?

      p0 = points[[i - 2, 0].max]
      p1 = points[i - 1]
      p2 = points[i]
      p3 = points[[i + 1, points.length - 1].min]

      # Catmull-Rom to cubic Bezier control points
      tension = 0.3
      cp1x = p1[:x] + (p2[:x] - p0[:x]) * tension
      cp1y = p1[:y] + (p2[:y] - p0[:y]) * tension
      cp2x = p2[:x] - (p3[:x] - p1[:x]) * tension
      cp2y = p2[:y] - (p3[:y] - p1[:y]) * tension

      path += " C #{cp1x.round(2)} #{cp1y.round(2)}, #{cp2x.round(2)} #{cp2y.round(2)}, #{p2[:x].round(2)} #{p2[:y].round(2)}"
    end

    path
  end

  def generate_fill_path(points, height, padding_y, chart_height)
    return "" if points.empty?

    line_path = generate_smooth_path(points)
    bottom_y = padding_y + chart_height

    # Close the path by going down to bottom, across, and back up
    "#{line_path} L #{points.last[:x]} #{bottom_y} L #{points.first[:x]} #{bottom_y} Z"
  end
end
