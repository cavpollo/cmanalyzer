var devices_data = null;

ready = function() {
    d3.select(window).on('resize', refresh_graphs);

    //#/---------------------------------------\
    //#|               QUERIES                 |
    //#\---------------------------------------/

    if ($('body.localstats.devices').length) {
        drawTotalBlock('#chart01', $('#chart01').attr('data-total'), 'Total Unique Devices')
        devices_ajax();
        $('#chart03-select').on('change', function(){devices_ajax()});
    }
    if ($('body.localstats.app_activity').length) {
        app_activity_ajax();
    }
};

refresh_graphs = function() {
    if ($('body.localstats.devices').length){
        drawPieGraph('#chart02', devices_data['brands']);
        drawPieGraph('#chart03', devices_data['models']);
    }
    if ($('body.localstats.app_activity').length){
        drawLineGraph('#chart01', devices_data['users_start_date']);
    }
};

devices_ajax = function(){
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

app_activity_ajax  = function(){
    $.ajax({
        type: 'GET',
        url: '/localstats/app_activity_data.json',
        data: {},
        dataType: 'json',
        success: function(result) {
            devices_data = result;
            drawLineGraph('#chart01', devices_data['users_start_date'], ['x', 'New Users']);
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

drawLineGraph = function (element, datasets, names) {
    var columns = [];
    var i=0;
    while (datasets.length > i) {
        datasets[i].unshift(names[i]);
        columns.push(datasets[i]);
        i++;
    }

    //Vertical Date Checkpoints
    var chart_key_points = []
    chart_key_points.push({value: '2016-02-29', text: 'FB Ads End'});
    chart_key_points.push({value: '2016-02-20', text: 'FB Ads Start'});
    chart_key_points.push({value: '2015-05-14', text: 'TV Show Tuti (FB Ads End)'}); //8PM, also 2015-05-15 12PM
    //chart_key_points.push({value: '2015-05-14', text: 'End FB Ads'} #12:55... Too Crammed
    chart_key_points.push({value: '2015-05-11', text: 'Start FB Ads'}); //13:17
    chart_key_points.push({value: '2014-10-22', text: 'v2.4.1'});
	//chart_key_points.push({value: '2014-10-22', text: 'v2.4.0'}); //Negiglible...
	//chart_key_points.push({value: '2014-10-21', text: 'v2.3.5'}); //Mess up fixed day after
    chart_key_points.push({value: '2014-09-14', text: 'v2.3.1'});
	//chart_key_points.push({value: '2014-09-14', text: 'v2.3.0'}); //Negiglible...
    chart_key_points.push({value: '2014-07-24', text: 'v2.1.1'});
	//chart_key_points.push({value: '2014-07-24', text: 'v2.1.0'}); //Negiglible
    chart_key_points.push({value: '2014-06-05', text: 'v1.1.0'}); //Stuck in flurry...
    chart_key_points.push({value: '2014-06-03', text: 'v1.0.14'}); //Stuck in flurry...

    c3.generate({
        axis: {
            x: {
                label: {
                    position: 'outer-center',
                    text: 'date'
                },
                type: 'timeseries',
                    tick: {
                    format: '%d/%m/%Y'
                }
            },
            y: {
                label: {
                    position: 'outer-middle',
                    text: 'New Users'
                }
            }
        },
        bindto: element,
        data: {
            x: 'x',
            columns: columns
        },
        grid: {
            x: {
                lines: chart_key_points
            }
        },
        size: {
            height: $(element).height(),
            width: $(element).width()
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