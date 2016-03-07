var devices_data = null;

ready = function() {
    d3.select(window).on('resize', refresh_graphs);

    //#/---------------------------------------\
    //#|               QUERIES                 |
    //#\---------------------------------------/

    if ($('body.localstats.devices').length) {
        drawTotalBlock('#chart01', $('#chart01').attr('data-total'), 'Total Unique Devices')
        models_ajax();
        $('#chart03-select').on('change', function(){models_ajax()});
    }
};

refresh_graphs = function() {
    if ($('body.localstats.devices').length){
        drawPieGraph('#chart02', devices_data['brands']);
        drawPieGraph('#chart03', devices_data['models']);
    }
};

models_ajax = function(){
	$.ajax({
		type: 'GET',
		url: '/localstats/devices_data.json',
		data: {brand: $('#chart03-select').val()},
		dataType: 'json',
		success: function(result) {
            devices_data = result;
            drawPieGraph('#chart02', devices_data['brands']);
            drawPieGraph('#chart03', devices_data['models']);
        },
		error: function(error) {
            console.log('error');
        }
    })
};


//#/---------------------------------------\
//#|                GRAPHS                 |
//#\---------------------------------------/

drawBarGraph = function(element, dataset) {
    var chartColumns = [];
    var chartColumnData = [];
    var chartColumnNames = [];

    chartColumnNames.push('x');
    chartColumnData.push('data');

    var i = 0;
    while (i < dataset.length) {
        chartColumnNames.push(dataset[i][0]);
        chartColumnData.push(dataset[i][1]);
        i++;
    }

    chartColumns.push(chartColumnNames);
    chartColumns.push(chartColumnData);

    c3.generate({
        axis: {
            x: {
                type: 'category'
            }
        },
        bar: {
            width: {
                ratio: 0.95
            }
        },
        bindto: element,
        data: {
            x: 'x',
            columns: chartColumns,
            groups: [['data']],
            type: 'bar'
        },
        legend: {
            show: false
        },
        size: {
            height: $(element).height(),
            width: $(element).width()
        }
    });
};

drawPieGraph = function (element, dataset) {
	var chartColumns = [];

    for (var key in dataset) {
        chartColumns.push([(key == '' ? 'UNKNOWN' : key) + ' (' + dataset[key]+ ')', dataset[key]]);
    }

	c3.generate({
		bindto: element,
		data: {
			columns: chartColumns,
			type: 'pie'
		},
		legend: {
			position: 'right'
		},
		size: {
			height: $(element).height(),
			width: $(element).width()
		},
		tooltip: {
            format: {
                title: function (d) {
                    return d
                },
                value: function (value, ratio, id) {
                    return value + ' - ' + Math.floor(ratio * 100) + '%'
                }
            }
        }
	});
};

drawTotalBlock = function(element, total, title) {
    $(element + ' > div > span.chart-count').html(total);
    $(element + ' > div > span.chart-title').html(title);
};

///---------------------------------------\
//|             Doc Stuff                 |
//\---------------------------------------/

$(document).ready(ready);
$(document).on('page:load', ready);