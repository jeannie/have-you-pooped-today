class TestopenflashController < ApplicationController

	def index
    # @graph = open_flash_chart_object(600,400,"/testopenflash/graph_code")
    title = Title.new("PPP Index")

    data1 = []

		data1 << 1.1
		data1 << 2.1
		data1 << 3.5
		data1 << 4.1
		data1 << 2.15
		data1 << 0.15

    line_dot = LineDot.new
    line_dot.text = "Line Dot"
    line_dot.width = 4
    line_dot.colour = '#DFC329'
    line_dot.dot_size = 5
    line_dot.values = data1

    y = YAxis.new
    y.set_range(0,5,0.5)

    x_legend = XLegend.new("")
    x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new("")
    y_legend.set_style('{font-size: 20px; color: #770077}')

    @chart =OpenFlashChart.new
    # chart.set_title(title)
    @chart.set_x_legend(x_legend)
    @chart.set_y_legend(y_legend)
    @chart.y_axis = y

    @chart.add_element(line_dot)

	end

  def graph_code
    title = Title.new("PPP Index")

    data1 = []

		data1 << 1.1
		data1 << 2.1
		data1 << 3.5
		data1 << 4.1
		data1 << 2.15
		data1 << 0.15

    line_dot = LineDot.new
    line_dot.text = "Line Dot"
    line_dot.width = 4
    line_dot.colour = '#DFC329'
    line_dot.dot_size = 5
    line_dot.values = data1

    y = YAxis.new
    y.set_range(0,5,0.5)

    x_legend = XLegend.new("")
    x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new("")
    y_legend.set_style('{font-size: 20px; color: #770077}')

    chart =OpenFlashChart.new
    # chart.set_title(title)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.y_axis = y

    chart.add_element(line_dot)

    render :text => chart.to_s
  end

end
