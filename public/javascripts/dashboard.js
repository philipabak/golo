  function showTooltip(x, y, contents) {
      $('<div id="tooltip">' + contents + '</div>').css( {
          position: 'absolute',
          display: 'none',
          top: y - 5,
          left: x + 10,
          border: '1px solid #fdd',
          padding: '2px',
          'background-color': '#fee',
          'color': '#000',
          opacity: 0.85
      }).appendTo("body").show();
  }

var previousPoint;
var baseline_level;
var average_golo;
var ymin;
var ymax;

$(document).ready(function() {
  $('#dataview').hide();

  var plot = $.plot($('#timechart'), time_chart_points, {
	  points: {show: true},
	lines: {show: true},
    xaxis: { mode: "time", timeformat: "%b %d"},
		yaxis: { tickFormatter: function(n, axis) { return "" + n + " miles" }, min: ymin, max: ymax },
    minTickSize: [1, "week"],
    grid: {
      show: true,
      //backgroundColor: '#111',
      color: '#555',
      tickColor: '#111',
      //labelMargin: number
		  markings: [
					 { color: '#f90', yaxis: { from: baseline_level, to: baseline_level } },
					 { color: '#ff0', yaxis: { from: average_golo, to: average_golo } }
					 ],
      //borderWidth: number
      //borderColor: color or null
      //clickable: true,
      hoverable: true,
		  autoHighlight: true
      //mouseActiveRadius: number
    },
    legend: {
      show: false,
      //labelFormatter: null or (fn: string, series object -> string)
      labelBoxBorderColor: 'green',
      //noColumns: number
      position: "nw",
      //margin: number of pixels or [x margin, y margin]
      backgroundColor: '#000',
      backgroundOpacity: 0.8
      //container: null or jQuery object/DOM element/jQuery expression
    }
  });
  // convert "25 pixels above line" to graph units
  var o = plot.pointOffset({ x: 2, y: baseline_level + (25.0 * (ymax - ymin) / 300.0)});
  $('#timechart').append('<div class="color_box descriptiion" id="your_baseline" style="position:absolute;left:60px;top:' + (o.top + 3) + 'px;">Your baseline: ' + baseline_level + ' miles/week</div>');
  o = plot.pointOffset({ x: 2, y: average_golo + (25.0 * (ymax - ymin) / 300.0)});
  $('#timechart').append('<div class="color_box descriptiion" id="avg_golo_user" style="position:absolute;left:60px;top:' + (o.top + 3) + 'px;">Average golo user: ' + average_golo + ' miles/week</div>');


  $("#timechart").bind("plothover", function (event, pos, item) {
      $("#x").text(pos.x.toFixed(2));
      $("#y").text(pos.y.toFixed(2));

      if (item) {
          if (previousPoint != item.datapoint) {
              previousPoint = item.datapoint;
                  
              $("#tooltip").remove();
              var x = item.datapoint[0].toFixed(2),
                  y = item.datapoint[1].toFixed(2);
			  var date = new Date(item.datapoint[0]);
			  var date_str = (date.getUTCMonth() + 1) + "/" + date.getUTCDate();
                  
              showTooltip(item.pageX, item.pageY, "" + y + " miles/week at " + date_str);
          }
      }
      else {
          $("#tooltip").remove();
          previousPoint = null;            
      }
  });
  

  $('#dataview_tab').click(function() {
    $('#timeview').hide('slow');
    $('#dataview').show('slow');
  });

  $('#timeview_tab').click(function() {
    $('#dataview').hide('slow');
    $('#timeview').show('slow');
  });

  $('.tab').click(function() {
    $(this).addClass('current');
    $(this).siblings().removeClass('current');
  });

  $('#how_to_update_baseline').hover(
  function() {
    $('#update_baseline_text').show();
  },
  function() {
    $('#update_baseline_text').hide();
  });

  $('#slideshow').cycle({
    fx: 'fade',
    timeout: 3000
  });

  $('#odometer_button').click(function() {
    $('.modal').hide();
    $('#odometer').removeClass('modalborder');
    $('#odometer').addClass('normalstate');
  });
});

