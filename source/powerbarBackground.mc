using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

const COLORS = [0x00ccff, 0x0066cff, 0x00ff22, 0xf6ff00, 0xffc600, 0xff00c0, 0xff0048];
const COLORS_WORST = Graphics.COLOR_LT_GRAY;
const COLORS_BAD = 0xff0048;
const COLORS_ALMOST = 0xffc600;
const COLORS_GOOD = 0x00ff22;

class Background extends WatchUi.Drawable {

    hidden var _color;
    hidden var app;
    hidden var _arrowHeight = 10.0;
    hidden var _watt = 0.0;
    hidden var _ftp = 0.0;
    hidden var _percentage = 0.0;
    hidden var _targetMode = 0;
    hidden var _target = [0,0];
    
    hidden var _scale = 0.0;
    hidden var _offset = 0.0;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        app = Application.getApp();
        _ftp = app.getProperty("ftp");
        if(_ftp == null) {
        	_ftp = 100.0;
    	}

        Drawable.initialize(dictionary);
    }

    function setColor(color) {
        _color = color;
    }
    
    function setValue(watt) {
    	_watt = watt;
    }
    
    function setTarget(target) {
    	_target = target;
    }
    
    function setMode(targetMode) {
    	_targetMode = targetMode;
    }
    
    function setPercentage(percentage) {
    	_percentage = percentage;
	}
	function setArrowHeight(arrowHeight) {
		_arrowHeight = arrowHeight;
	}

    function draw(dc) {
    dc.setColor(Graphics.COLOR_TRANSPARENT, _color);
    dc.clear();
    switch (_targetMode) {
      case 0:
        _scale = 0.8;
        _offset = -30.0;
        drawNormal(dc);
        break;
      case 1:
        drawZone(dc);
        break;
      case 2:
        drawCustom(dc);
        break;
    }
    drawValue(dc, _watt);
  }

  function drawNormal(dc) {
    var zones = [];
    for (var i = 0; i < app.zones.size(); i++) {
      zones.add(app.zones[i] * _scale);
    }
    drawBars(dc, COLORS, zones, _offset / 100);
  }

  /**
   *
   * @param dc DC
   */
  function drawZone(dc) {
    var z = _target[0] - 1;
    var yS1, yS2, yZ1, yZ2;
    var zones, colors;
    if (z == 0) {
      // Z1
      zones = [0.5, 0.6, 0.7, 0.8];
      colors = [
        COLORS_GOOD,
        COLORS_ALMOST,
        COLORS_BAD,
        COLORS_WORST,
        COLORS_WORST,
      ];

      yS1 = 0;
      yS2 = zones[0];
      yZ1 = 0;
      yZ2 = app.zones[z];
    } else if (z == 6) {
      // Z7
      zones = [0.2, 0.3, 0.4, 0.5];
      colors = [
        COLORS_WORST,
        COLORS_BAD,
        COLORS_ALMOST,
        COLORS_GOOD,
        COLORS_GOOD,
      ];

      yS1 = 0.4;
      yS2 = 1;
      yZ1 = app.zones[z - 1];
      yZ2 = yZ1 + 1.0;
    } else {
      // Z2 - Z6
      zones = [0.10, 0.18, 0.26, 0.74, 0.82, 0.90];
      colors = [
        COLORS_WORST,
        COLORS_BAD,
        COLORS_ALMOST,
        COLORS_GOOD,
        COLORS_ALMOST,
        COLORS_BAD,
        COLORS_WORST,
      ];

      yS1 = zones[2];
      yS2 = zones[3];
      yZ1 = app.zones[z - 1];
      yZ2 = app.zones[z];
    }
    drawBars(dc, colors, zones, 0);
    _scale = (yS2 - yS1) / (yZ2 - yZ1);
    _offset = (yS1 * 100) - (_scale * yZ1 * 100);
  }

  function drawCustom(dc) {
    var yS1, yS2, yZ1, yZ2;
    var zones, colors;
    zones = [0.10, 0.18, 0.26, 0.74, 0.82, 0.90];
    colors = [
      COLORS_WORST,
      COLORS_BAD,
      COLORS_ALMOST,
      COLORS_GOOD,
      COLORS_ALMOST,
      COLORS_BAD,
      COLORS_WORST,
    ];

    yS1 = zones[2];
    yS2 = zones[3];
    yZ1 = (100.0 * _target[0]) / _ftp / 100;
    yZ2 = (100.0 * _target[1]) / _ftp / 100;
    drawBars(dc, colors, zones, 0);
    _scale = (yS2 - yS1) / (yZ2 - yZ1);
    _offset = (yS1 * 100) - (_scale * yZ1 * 100);
  }

  function drawBars(dc, colors, zones, offset) {
    var screenWidth = dc.getWidth();
    var screenHeight = dc.getHeight();
    var x = 0;
    var w = 0;
    for (var i = 0; i <= zones.size(); i++) {
      if (i == zones.size()) {
        w = 1 - zones[i - 1] - offset;
      } else {
        w = zones[i] - x;
      }
      dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
      
      var xo = (x + offset) * screenWidth;
      var wo = w * screenWidth;
      dc.fillRectangle(
        Math.floor((x + offset) * screenWidth),
        screenHeight - 10,
        Math.floor(w * screenWidth) + 1,
        10
      );
	  if (i < zones.size()) {
      	x = zones[i] * 1;
	  }
    }
  }

  function drawValue(dc, pwr) {
    var screenWidth = dc.getWidth();
    var screenHeight = dc.getHeight();
    var perc = _percentage * 100;
    var pos = ((perc * _scale + _offset) / 100) * screenWidth;
	pos = pos < 0 ? 0 : pos;
	pos = pos > screenWidth ? screenWidth: pos;
	
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon([
      [pos + 1, screenHeight - 10],
      [pos - 4, screenHeight - (10  + _arrowHeight)],
      [pos + 1, screenHeight - 10],
      [pos + 5, screenHeight - (10  + _arrowHeight)],
      [pos - 4, screenHeight - (10  + _arrowHeight)],
    ]);
  }
}
