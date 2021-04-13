using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

const COLORS = [0x00ccff, 0x0066cff, 0x00ff22, 0xf6ff00, 0xffc600, 0xff00c0, 0xff0048];
const COLORS_WORST = Graphics.COLOR_LT_GRAY;
const COLORS_BAD = 0xff0048;
const COLORS_ALMOST = 0xffc600;
const COLORS_GOOD = 0x00ff22;

class Background extends WatchUi.Drawable {

    hidden var mColor;
    hidden var app;
    hidden var _watt = 0.0;
    hidden var _ftp = 0.0;
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

        Drawable.initialize(dictionary);
    }

    function setColor(color) {
        mColor = color;
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

    function draw(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, mColor);
        dc.clear();
        switch(_targetMode) {
        	case 0:
	        	drawNormal(dc);
	        	_scale = 200.0;
	        	break;
        	case 1:
        		drawZone(dc);
        		break;
        }
		drawValue(dc, _watt);
        
        
    }

	function drawNormal(dc) {
		var zones = [];
		for(var i = 0; i < app.zones.size(); i++) {
			zones.add(app.zones[i] / 2);
		}
		drawBars(dc, COLORS, zones);
	}
	
	function drawZone(dc) {
	
        var screenWidth = dc.getWidth();
        var h = dc.getHeight();
        var z = _target[0] - 2;
        if(z >= 0) {
	        var zMin = z == 0 ? 0 : app.zones[z-1];
        	var zMax = app.zones[z];
        }
        
        if(z == 0) {
	        // Z1
	        var zones = [0.5, 0.6, 0.7, 0.8];
	        var colors = [COLORS_GOOD, COLORS_ALMOST, COLORS_BAD, COLORS_WORST, COLORS_WORST];
	        drawBars(dc, colors, zones);
	        _offset = 0.0;
	        _scale = screenWidth / app.zones[z] / .5;
        } else if(z == 6) {
        	// Z7
	        var zones = [0.2, 0.3, 0.4, 0.5];
	        var colors = [COLORS_WORST, COLORS_BAD, COLORS_ALMOST, COLORS_GOOD, COLORS_GOOD];
	        drawBars(dc, colors, zones);
			
          	_offset = 25.0;
          	_scale = 50;
        } else {
        	// Z2 - Z6
	        var zones = [0.15, 0.23, 0.31, 0.69, 0.77, 0.85];
	        var colors = [COLORS_WORST, COLORS_BAD, COLORS_ALMOST, COLORS_GOOD, COLORS_ALMOST, COLORS_BAD, COLORS_WORST];
	        drawBars(dc, colors, zones);
	        
          	_scale =(screenWidth * 0.38) / (app.zones[zone] - app.zones[zone - 1]);
          	_offset = screenWidth * 0.31 - _scale * app.zones[zone - 1];
        }
        
	}
	
	function drawBars(dc, colors, zones) {
		var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
		var start = 0;
        for(var i = 0; i <= zones.size(); i++) {
        	var end = screenWidth;
        	if(i < zones.size()) {
	        	end = zones[i] * screenWidth;
        	}
        	dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(start, screenHeight - 10, end, screenHeight);
        	start = end;
        }
	}

	function drawValue(dc, pwr) {
		var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
		var perc = 100.0 * pwr / _ftp / 100.0;
		var pos = perc * _scale + _offset;
		// pos = 0 > pos ? 0 : pos;
		// pos = pos < screenWidth ? pos : screenWidth;
		System.println("power: " + pwr + "; ftp: " + _ftp + "; perc: " + perc + "; pos: " + pos);
		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawLine(pos, screenHeight, pos, screenHeight - 10);
	}
	
	function getPosition() {
		var percOfFtp = _watt / _ftp;
		var positionInPercentage = (percOfFtp / _scale);
		return positionInPercentage;
	}
}
