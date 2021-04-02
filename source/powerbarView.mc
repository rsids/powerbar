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

    hidden var mValue;
    hidden var powers = [0,0,0];
    hidden var power3s = 0.0;
    hidden var power = 0.0;
    hidden var powerPos = 0;
    hidden var ftp;
    hidden var zone;
    hidden var app;
    hidden var targetMode = 0;
    hidden var target = [0,0];

    function initialize() {
        DataField.initialize();
        app = Application.getApp();
        mValue = 0.0f;
        ftp = 258.0;
        zone = 1;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

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
        	target = [act.step.targetValueLow, act.step.targetValueHigh];
        	System.println(SPORT_NAMES[act.sport] +": " + TARGET_NAMES[act.step.targetType] + "; " + INTENSITY_NAMES[act.intensity] + "; " + act.step.targetValueLow + " / " + act.step.targetValueHigh);
        }
        if(info has :currentPower){
            if(info.currentPower != null){
                power = info.currentPower;
                powers[powerPos] = power;
                powerPos++;
                if(powerPos == 3) {
                	powerPos = 0;
            	}
            	power3s = (powers[0] + powers[1] + powers[2]) / 3;
            	var perc = power3s / ftp;
            	for(var i = app.zones.size() - 1; i >= 0; i--) {
            		if(perc < app.zones[i]) {
            			zone = i+1;
            		}
            	}
            	
            	mValue = perc * 100;
            } else {
                mValue = 0.0f;
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
        bg.setValue(mValue);

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        var fgColor = Graphics.COLOR_BLACK;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            fgColor = Graphics.COLOR_WHITE;
        }
	    value.setColor(fgColor);
        value.setText(power3s.format("%.0f") + " / Z" + zone);

		var w = dc.getWidth();
		var h = dc.getHeight();
		var x = w * mValue / 200;
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
