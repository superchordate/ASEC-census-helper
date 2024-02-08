document.addEventListener('DOMContentLoaded', function() { Highcharts.setOptions({
    chart: {
        style: {fontSize: '12pt', fontFamily: 'Sans-Serif'},
        width: 400*1.6, height: 400 // golden ratio.
    },
    title: {text: ''}, 
    legend: {verticalAlign: 'top', enabled: false},
    yAxis: {
        startOnTick: true, endOnTick: true,
        labels: {enabled: false}, 
        title: {enabled: false},
    },
    xAxis: {
        startOnTick: true, endOnTick: true,
        lineWidth: 0, tickWidth: 0, gridLineWidth: 1, 
        title: {enabled: true, text: 'Values', style: {fontSize: '12pt'}}
    },
    plotOptions: {
        series: {
           enableMouseTracking: false,
           dataLabels: {
              enabled: true,
              backgroundColor: 'rgba(255, 255, 255, 0.5)',
              padding: 0,
              allowOverlap: false,
              style: {
                textOutline: 'none',
                fontSize: '12pt'
             }
           }
        }
     },
    credits: {enabled: false}
})});