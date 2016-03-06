devices_data = null

ready = ->
	d3.select(window).on('resize', refresh_graphs)

	#/---------------------------------------\
	#|               QUERIES                 |
	#\---------------------------------------/

	if $('body.localstats.devices').length
		$.ajax
			type: 'GET'
			url: '/localstats/devices_data.json'
			data: {}
			dataType: 'json'
			success: (result) ->
				devices_data = result
				drawPieGraph '#chart01', devices_data['brands']
				drawPieGraph '#chart02', devices_data['models']
				return
			error: (xhr, status, error) ->
				console.log 'error'
				return

refresh_graphs = ->
	if $('body.localstats.devices').length
		drawPieGraph '#chart01', devices_data['brands']
		drawPieGraph '#chart02', devices_data['models']
	return

#/---------------------------------------\
#|                GRAPHS                 |
#\---------------------------------------/

drawBarGraph = (element, dataset) ->
	chartColumns = []
	chartColumnData = []
	chartColumnNames = []

	chartColumnNames.push 'x'
	chartColumnData.push 'data'

	i = 0
	while i < dataset.length
		chartColumnNames.push dataset[i][0]
		chartColumnData.push dataset[i][1]
		i++

	chartColumns.push chartColumnNames
	chartColumns.push chartColumnData

	c3.generate({
		axis: {
			x: {
				type: 'category'
			}
		}
		bar: {
			width: {
				ratio: 0.95
			}
		}
		bindto: element
		data: {
			x: 'x'
			columns: chartColumns
			groups: [['data']]
			type: 'bar'
		}
		legend: {
			show: false
		}
		size: {
			height: $(element).height()
			width: $(element).width()
		}
	})

	return

drawPieGraph = (element, dataset) ->
	chartColumns = []

	for key of dataset
		chartColumns.push [
			if key == '' then 'UNKNOWN' else key
			dataset[key]
		]

	c3.generate({
		bindto: element
		data: {
			columns: chartColumns
			type: 'pie'
		}
		legend: {
			position: 'right'
		}
		size: {
			height: $(element).height()
			width: $(element).width()
		}
		tooltip:
			format:
				title: (d) ->
					return d
				value: (value, ratio, id) ->
					return value + ' - ' + Math.floor(ratio*100) + '%'
	})

	return

drawTotalBlock = (element, dataset) ->
	$(element + ' > div > span.chart-count').html(dataset['total']);
	$(element + ' > div > span.chart-title').html(dataset['title']);

	return

#/---------------------------------------\
#|             Doc Stuff                 |
#\---------------------------------------/

$(document).ready ready
$(document).on 'page:load', ready