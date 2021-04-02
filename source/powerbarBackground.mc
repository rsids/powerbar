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
    hidden var _watt = 0;
    hidden var _targetMode = 0;
    hidden var _target = [0,0];
    
    hidden var _scale = 0.0;
    hidden var _offset = 0.0;
    hidden var _ftp = 258.00

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        app = Application.getApp();

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
	        	break;
        	case 1:
        		drawZone(dc);
        		break;
        }
        
        
    }

	function drawNormal(dc) {
//        var w = dc.getWidth();
//        var h = dc.getHeight();
//		var s = 0;
		var zones = [];
		for(var i = 0; i < app.zones.size(); i++) {
			zones.add(app.zones[i] / 2);
		}
		drawBars(dc, COLORS, zones);
//        for(var i = 0; i < 7; i++) {
//        	var x = w;
//        	if(i < 6) {
//	        	x = app.zones[i] * w / 2;
//        	}
//        	dc.setColor( COLORS[i], Graphics.COLOR_TRANSPARENT);
//        	dc.fillRectangle(s, h - 10, x, h);
//        	s = x;
//        }
        
	}
	
	function drawZone(dc) {
	
        var w = dc.getWidth();
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
	        _scale = app.zones[z] / .5;
        } else if(z == 6) {
        	// Z7
	        var zones = [0.2, 0.3, 0.4, 0.5];
	        var colors = [COLORS_WORST, COLORS_BAD, COLORS_ALMOST, COLORS_GOOD, COLORS_GOOD];
	        drawBars(dc, colors, zones);
        } else {
        	// Z2 - Z6
	        var zones = [0.15, 0.23, 0.31, 0.69, 0.77, 0.85];
	        var colors = [COLORS_WORST, COLORS_BAD, COLORS_ALMOST, COLORS_GOOD, COLORS_ALMOST, COLORS_BAD, COLORS_WORST];
	        drawBars(dc, colors, zones);
	        
	        var spread = zones[z] - zones[z-1];
	        var scale = spread / .38;
	        var middle = zones[z-1] + (spread / 2);
			var percOfFtp = watt / ftp;
	        
	        // Calc % of FTP
	        // Add / subtract from middle
	        // Multiply by scale
        }
        
	}
	
	function drawBars(dc, colors, zones) {
		var w = dc.getWidth();
        var h = dc.getHeight();
		var start = 0;
        for(var i = 0; i <= zones.size(); i++) {
        	var end = w;
        	if(i < zones.size()) {
	        	end = zones[i] * w;
        	}
        	dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(start, h - 10, end, h);
        	start = end;
        }
	}
	
	function drawValue(dc, pos) {    
        var h = dc.getHeight();
		var w = dc.getWidth();
		var x = w * pos;
		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawLine(x, h, x, h-10);
	}
	
	function getPosition() {
		var percOfFtp = watt / ftp;
		var positionInPercentage = (percOfFtp / scale);
		return positionInPercentage;
	}
}
