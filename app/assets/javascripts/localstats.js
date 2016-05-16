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
        drawTotalBlock('#chart01', $('#chart01').attr('data-total'), 'Total Unique Devices');
        devices_ajax();
        $('#chart03-select').on('change', function(){devices_ajax()});
    }
    if ($('body.localstats.app_activity').length) {
        app_activity_ajax();
    }
    if ($('body.localstats.loss_activity').length) {
        loss_activity_ajax();
    }
};

refresh_graphs = function() {
    if ($('body.localstats.devices').length){
        drawPieGraph('#chart02', devices_data['brands']);
        drawPieGraph('#chart03', devices_data['models']);
    }
    if ($('body.localstats.app_activity').length){
        drawLineGraph('#chart01', devices_data['users_start_date'], ['Fecha', 'Total de Usuarios'], ['Fecha', 'First Plays', 'Last Plays', '1 Day Players', 'Installs', 'Upgrades', 'Uninstalls']);
        drawBarGraph('#chart02', devices_data['users_day_of_use'], ['# de Dias de Uso', 'Dias Uso', 'Dias Uso Sin 1er Dia'], true);
        drawTotalBlock('#chart03', devices_data['users_average_days_of_use'], 'Dias de Uso Promedio');
        drawTotalBlock('#chart04', devices_data['users_above_average_days_of_use'], 'Usuarios por encima de Uso Promedio');
        drawTotalBlock('#chart05', devices_data['users_median_days_of_use'], 'Dias de Uso Mediana (Sin 1er Dia)');
    }
    if ($('body.localstats.loss_activity').length) {
        drawBarGraph('#chart01', devices_data['ratio_count'], ['Densidad de pantalla', 'Todos los Usuarios', 'Usuarios 1 dia'], true);
        drawScatterGraph('chart02', devices_data['ratio_vs_days_of_use'], ['Densidad de Pantalla', 'Dias de uso']);
        drawBarGraph('#chart03', devices_data['prop_count'], ['Proporcion de pantalla', 'Todos los Usuarios', 'Usuarios 1 dia'], true);
        drawScatterGraph('chart04', devices_data['prop_vs_days_of_use'], ['Proporcion de Pantalla', 'Dias de Uso']);
        drawBarGraph('#chart05', devices_data['h_count'], ['Altura de pantalla', 'Todos los Usuarios', 'Usuarios 1 dia'], true);
        drawScatterGraph('chart06', devices_data['h_vs_days_of_use'], ['Altura de Pantalla', 'Dias de Uso']);
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
            drawLineGraph('#chart01', devices_data['users_start_date'], ['Fecha', 'Total de Usuarios'], ['Fecha', 'First Plays', 'Last Plays', '1 Day Players', 'Installs', 'Upgrades', 'Uninstalls']);
            drawBarGraph('#chart02', devices_data['users_day_of_use'], ['# de Dias de Uso', 'Dias Uso', 'Dias Uso Sin 1er Dia'], true);
            drawTotalBlock('#chart03', devices_data['users_average_days_of_use'], 'Dias de Uso Promedio');
            drawTotalBlock('#chart04', devices_data['users_above_average_days_of_use'], 'Usuarios por encima de Uso Promedio');
            drawTotalBlock('#chart05', devices_data['users_median_days_of_use'], 'Dias de Uso Mediana (Sin 1er Dia)');
        },
        error: function(error) {
            console.log('error');
        }
    })
};

loss_activity_ajax  = function(){
    $.ajax({
        type: 'GET',
        url: '/localstats/loss_activity_data.json',
        data: {},
        dataType: 'json',
        success: function(result) {
            devices_data = result;
            drawBarGraph('#chart01', devices_data['ratio_count'], ['Densidad de pantalla', 'Todos los Usuarios', 'Usuarios 1 dia'], true);
            drawScatterGraph('chart02', devices_data['ratio_vs_days_of_use'], ['Densidad de Pantalla', 'Dias de Uso']);
            drawBarGraph('#chart03', devices_data['prop_count'], ['Proporcion de pantalla', 'Todos los Usuarios', 'Usuarios 1 dia'], true);
            drawScatterGraph('chart04', devices_data['prop_vs_days_of_use'], ['Proporcion de Pantalla', 'Dias de Uso']);
            drawBarGraph('#chart05', devices_data['h_count'], ['Altura de pantalla', 'Todos los Usuarios', 'Usuarios 1 dia'], true);
            drawScatterGraph('chart06', devices_data['h_vs_days_of_use'], ['Altura de Pantalla', 'Dias de Uso']);
        },
        error: function(error) {
            console.log('error');
        }
    })
};


//#/---------------------------------------\
//#|                GRAPHS                 |
//#\---------------------------------------/

drawScatterGraph = function (element, dataset, axis){
    var chart = new CanvasJS.Chart(element, {
        zoomEnabled: true,
        animationEnabled: true,
        axisX: {
            title: axis[0],
            //minimum: 0.5,
            //labelAngle: -40,
            //maximum: 4.1,
            labelFontSize: 14,
            titleFontSize: 18
        },
        axisY:{
            title: axis[1],
            //valueFormatString: "$#,##0k",
            lineThickness: 2,
            labelFontSize: 14,
            titleFontSize: 18
        },
        data: [
            {
                type: 'bubble',
                toolTipContent: '<span style="color: {color};"><strong>{z} personas</strong></span><br/><strong>'+axis[0]+'</strong> {x} <br/> <strong>'+axis[1]+'</strong> {y}',
                dataPoints: dataset
            }

        ]
    });

    chart.render();
};

drawCandleGraph = function (element, dataset){
    //Open, High, Low, Close

    // --- High
    //  |
    // ___ Open
    // | |
    // | |
    // L__ Close
    //  |
    // --- Low

    var chart = new CanvasJS.Chart(element,
        {
            axisY: {
                includeZero: false,
                //prefix: "$",
            },
            axisX: {
                //valueFormatString: "DD-MMM",
            },
            data: [
                {
                    type: "candlestick",
                    dataPoints: dataset
                }
            ]
        });

    chart.render();
};

drawBarGraph = function(element, dataset, names, legend) {
    var chartColumns = [];
    var chartColumnData = [];
    var chartColumnNames = [];

    chartColumnNames.push(names[0]);
    var j = 0;
    while (j+1 < names.length) {
        chartColumnData[j] = [names[j+1]];
        j++;
    }

    var i = 0;
    while (i < dataset.length) {
        chartColumnNames.push(dataset[i][0]);
        var j = 0;
        while (j+1 < names.length) {
            chartColumnData[j].push(dataset[i][j+1]);
            j++;
        }
        i++;
    }

    chartColumns.push(chartColumnNames);
    var j = 0;
    while (j+1 < names.length) {
        chartColumns.push(chartColumnData[j]);
        j++;
    }

    c3.generate({
        axis: {
            x: {
                label: {
                    position: 'outer-center',
                    text: names[0]
                },
                type: 'category'
            },
            y: {
                label: {
                    position: 'outer-middle',
                    text: 'Total'
                }
            }
        },
        bar: {
            width: {
                ratio: 0.95
            }
        },
        bindto: element,
        data: {
            x: names[0],
            columns: chartColumns,
            groups: [names.splice(0, 1)],
            type: 'bar'
        },
        legend: {
            show: legend
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

drawLineGraph = function (element, datasets, axis, names) {
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
                    text: axis[0]
                },
                type: 'timeseries',
                    tick: {
                    format: '%d/%m/%Y'
                }
            },
            y: {
                label: {
                    position: 'outer-middle',
                    text: axis[1]
                }
            }
        },
        bindto: element,
        data: {
            x: axis[0],
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