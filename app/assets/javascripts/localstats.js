var devices_data = null;
var startDate = moment('03/06/2014', 'DD/MM/YYYY');
var endDate = moment().add(1, 'days');

ready = function() {
    d3.select(window).on('resize', refresh_graphs);

    //#/---------------------------------------\
    //#|               DATE                    |
    //#\---------------------------------------/

    $('#daterange span').html(moment('02/06/2014', 'DD/MM/YYYY').format('D/MM/YYYY') + ' - ' + moment().format('D/MM/YYYY'));

    $('#daterange').daterangepicker({
        format: 'DD/MM/YYYY',
        startDate: moment('02/06/2014', 'DD/MM/YYYY').format('D/MM/YYYY'),
        endDate: moment().format('DD/MM/YYYY'),
        minDate: '02/06/2014',
        maxDate: moment().add(1, 'days').format('DD/MM/YYYY'),
        dateLimit: {
            years: 5
        },
        showDropdowns: true,
        showWeekNumbers: false,
        timePicker: false,
        timePickerIncrement: 1,
        timePicker12Hour: true,
        ranges: {
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(29, 'days'), moment()],
            'Last 60 days': [moment().subtract(59, 'days'), moment()],
            'Last 6 months': [moment().subtract(179, 'days'), moment()],
            'Last year': [moment().subtract(365, 'days'), moment()]
        },
        opens: 'left',
        drops: 'down',
        buttonClasses: ['btn', 'btn-sm'],
        applyClass: 'btn-primary',
        cancelClass: 'btn-default',
        separator: ' to ',
        locale: {
            applyLabel: 'Submit',
            cancelLabel: 'Cancel',
            fromLabel: 'From',
            toLabel: 'To',
            customRangeLabel: 'Custom',
            daysOfWeek: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
            monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
            firstDay: 1
        }
    }, function(start, end, label) {});

    $('#daterange').on('apply.daterangepicker', function(ev, picker) {
        $('#daterange span').html(picker.startDate.format('D/MM/YYYY') + ' - ' + picker.endDate.format('D/MM/YYYY'));
        startDate = picker.startDate;
        endDate = picker.endDate.add(1, 'days');
        refresh_graphs();
    });

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
        drawLineGraph('#chart01', devices_data['users_start_date'], ['x', 'First Plays', 'Installs', 'Upgrades', 'Uninstalls']);
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
            drawLineGraph('#chart01', devices_data['users_start_date'], ['x', 'First Plays', 'Installs', 'Upgrades', 'Uninstalls']);
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
        columns.push([names[i]].concat(datasets[i]));
        i++;
    }

    var j = 1;
    while (columns[0].length > j) {
        if(startDate > moment(columns[0][j], 'YYYY-MM-DD') || moment(columns[0][j], 'YYYY-MM-DD') > endDate) {
            i = 0;
            while (columns.length > i) {
                columns[i].splice(j, 1);
                i++;
            }
        } else {
            j++;
        }
    }

    //Vertical Date Checkpoints
    var chart_key_points = [];
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
                    text: 'Total'
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