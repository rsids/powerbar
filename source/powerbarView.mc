using Toybox.WatchUi;
using Toybox.Graphics;

const SPORT_CYCLING = 2;
const POWER_3S = 7;

const TARGET_MODE_NONE = 0;
const TARGET_MODE_ZONE = 1;
const TARGET_MODE_POWER = 2;

const INTENSITY_NAMES = [
    "ACTIVE",
    "REST",
    "WARMUP",
    "COOLDOWN",
    "RECOVERY",
    "INTERVAL"
];

const DURATION_NAMES = [
    "TIME",
    "DISTANCE",
    "HR_LESS_THAN",
    "HR_GREATER_THAN",
    "CALORIES",
    "OPEN",
    "REPEAT_UNTIL_STEPS_COMPLETE",
    "REPEAT_UNTIL_TIME",
    "REPEAT_UNTIL_DISTANCE",
    "REPEAT_UNTIL_CALORIES",
    "REPEAT_UNTIL_HR_LESS_THAN",
    "REPEAT_UNTIL_HR_GREATER_THAN",
    "REPEAT_UNTIL_POWER_LESS_THAN",
    "REPEAT_UNTIL_POWER_GREATER_THAN",
    "POWER_LESS_THAN",
    "POWER_GREATER_THAN",
    "TRAINING_PEAKS_TRAINING_STRESS_SCORE",
    "REPEAT_UNTIL_POWER_LAST_LAP_LESS_THAN",
    "REPEAT_UNTIL_MAX_POWER_LAST_LAP_LESS_THAN",
    "POWER_3S_LESS_THAN",
    "POWER_10S_LESS_THAN",
    "POWER_30S_LESS_THAN",
    "POWER_3S_GREATER_THAN",
    "POWER_10S_GREATER_THAN",
    "POWER_30S_GREATER_THAN",
    "POWER_LAP_LESS_THAN",
    "POWER_LAP_GREATER_THAN",
    "REPEAT_UNTIL_TRAINING_PEAKS_TRAINING_STRESS_SCORE",
    "REPETITION_TIME",
    "REPS",
];

const TARGET_NAMES = [
    "SPEED",
    "HEART_RATE",
    "OPEN",
    "CADENCE",
    "POWER",
    "GRADE",
    "RESISTANCE",
    "POWER_3S",
    "POWER_10S",
    "POWER_30S",
    "POWER_LAP",
    "SWIM_STROKE",
    "SPEED_LAP",
    "HEART_RATE_LAP",
    "INHALE_DURATION",
    "INHALE_HOLD_DURATION",
    "EXHALE_DURATION",
    "EXHALE_HOLD_DURATION",
    "POWER_CURVE",
];

const SPORT_NAMES = [
    "GENERIC",
    "RUNNING",
    "CYCLING",
    "TRANSITION",
];


class powerbarView extends WatchUi.DataField {

    hidden var powers = [0,0,0];
    hidden var power3s = 0.0;
    hidden var power = 0.0;
    hidden var powerPos = 0;
    hidden var percentage = 0.0;
    hidden var ftp;
    hidden var zone;
    hidden var app;
    hidden var targetMode = 0;
    hidden var target = [0,0];
    hidden var targetW = [0.0,0.0];
	hidden var arrowHeight = 10;

	hidden var dStep = 10.0;
	hidden var dDir = 1;

    function initialize() {
        DataField.initialize();
        app = Application.getApp();
        ftp = app.getProperty("ftp");
        zone = 1;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
		var height = dc.getHeight();
		System.println(height);
		var labelOffset = -16;
		var valueOffset = 7;
		var rangeOffset = -25;
		if(height >= 125) {
	    	View.setLayout(Rez.Layouts.MainLayoutMD(dc));
	    	labelOffset = -18;
	    	valueOffset = 9;
	    	rangeOffset = -45;
	    	arrowHeight = 15;
	    } else if (height > 78) {
	    	View.setLayout(Rez.Layouts.MainLayoutSM(dc));
	    	arrowHeight = 10;
			labelOffset = -25;
			valueOffset = -2;
	    	rangeOffset = -35;
	    } else {
	    	View.setLayout(Rez.Layouts.MainLayoutXS(dc));
			labelOffset = -25;
			valueOffset = -2;
	    	arrowHeight = 10;
	    }
	    
	    var labelView = View.findDrawableById("label");
	    labelView.locY = labelView.locY + labelOffset;
	    var valueView = View.findDrawableById("value");
	    valueView.locY = valueView.locY + valueOffset;
	    
	    var vMin = View.findDrawableById("vMin");
	    var vMax = View.findDrawableById("vMax");
	    vMin.locY = vMin.locY + rangeOffset;
	    vMax.locY = vMax.locY + rangeOffset;
        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var act = Activity.getCurrentWorkoutStep();
        targetMode = TARGET_MODE_NONE;
        if(act != null && act.sport == SPORT_CYCLING && act.step.targetType == POWER_3S) {
        	targetMode = act.step.targetValueLow < 1000 ? TARGET_MODE_ZONE : TARGET_MODE_POWER;
        	if(targetMode == TARGET_MODE_ZONE) {
        		target = [act.step.targetValueLow -1, act.step.targetValueHigh];
        		targetW[0] = 0.0;
    			if(target[0] == 7) {
					targetW[1] = 999;
				} else {
    				targetW[1] = ftp * app.zones[target[0] - 1];
				}
        		if(target[0] > 1) {
        			targetW[0] = ftp * app.zones[target[0] - 2];
				}
        	} else {
        		target = [act.step.targetValueLow - 1000, act.step.targetValueHigh - 1000];
        		targetW = [act.step.targetValueLow - 1000, act.step.targetValueHigh - 1000];
        	}
        }        
        		
        if(info has :currentPower){
            if(info.currentPower != null){
                power = info.currentPower;

                powers[powerPos] = power;
                powerPos++;
                if(powerPos == 3) {
                	powerPos = 0;
            	}
            	power3s = (powers[0] + powers[1] + powers[2]) / 3.0;
            	percentage = power3s / ftp;
            	zone = 7;
            	for(var i = app.zones.size() - 1; i >= 0; i--) {
            		if(percentage < app.zones[i]) {
            			zone = i+1;
            		}
            	}
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        var bg = View.findDrawableById("Background");
        bg.setColor(getBackgroundColor());
        bg.setMode(targetMode);
        bg.setTarget(target);
        bg.setValue(power3s);
        bg.setPercentage(percentage);
        bg.setArrowHeight(arrowHeight);

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        var vMin =  View.findDrawableById("vMin");
        var vMax = View.findDrawableById("vMax");
        var fgColor = Graphics.COLOR_BLACK;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            fgColor = Graphics.COLOR_WHITE;
        }
	    value.setColor(fgColor);
	    vMin.setColor(fgColor);
	    vMax.setColor(fgColor);
        value.setText(power3s.format("%.0f") + " / Z" + zone);
        if(targetMode == TARGET_MODE_NONE) {
            vMin.setText("");
            vMax.setText("");
        } else {
	        if(targetW[0] > 0) {
	        	// Zones 2 - 6 or defined watts
	            vMin.setText(targetW[0].format("%.0f"));
	        	vMax.setText(targetW[1].format("%.0f"));
	        	if(targetW[1] == 999) {
		        	// Zone 7
		            vMin.setText("");
		            vMax.locX = dc.getWidth() * 0.4;
		        	vMax.setText(">" + targetW[0].format("%.0f"));
	        	}
	        } else {
	        	// Zone 1
	            vMin.setText("");
	            vMax.locX = dc.getWidth() * 0.5;
	        	vMax.setText("< " + targetW[1].format("%.0f"));
	        }
        }

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
