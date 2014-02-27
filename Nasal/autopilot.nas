##

var adjust_vs_factor = func {
	var vs_knob = getprop("/autopilot/settings/vertical-speed-knob");
	vs = vs_knob * 50;

	if (vs_knob >  20) vs = vs + (vs_knob - 20) * 50;
	if (vs_knob < -20) vs = vs + (vs_knob + 20) * 50;

	setprop ("/autopilot/settings/vertical-speed-fpm", vs);
}

adjust_vs_factor(); # first run to create properties
setlistener( "/autopilot/settings/vertical-speed-knob", adjust_vs_factor, 0, 0);

var vs_button_press = func {
if (getprop("/autopilot/switches/VS-button") == 1) {
	setprop("/autopilot/switches/VS-button", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 0);
	setprop("/autopilot/internal/LVLCHG", 0);

	if (getprop("/autopilot/internal/VNAV-VS") == 1) {
		setprop("/autopilot/internal/VNAV-VS", 0);
	} else {
		var vs_fpm_current = getprop("/velocities/vertical-speed-fps") * 60;

		if (vs_fpm_current < 1000 and vs_fpm_current > -1000) {
			round_value = 50;
		} else {
			round_value = 100;
		}
		vs_fpm_current = math.round(vs_fpm_current, round_value);

		if (vs_fpm_current < -7900) vs_fpm_current = -7900;
		if (vs_fpm_current > 6000) vs_fpm_current = 6000;

		vs_knob = vs_fpm_current / 50;
		if (vs_fpm_current >  1000) vs_knob = vs_knob - (vs_fpm_current - 1000) / 100;
		if (vs_fpm_current < -1000) vs_knob = vs_knob - (vs_fpm_current + 1000) / 100;
		setprop("/autopilot/settings/vertical-speed-knob", vs_knob);
		setprop("/autopilot/internal/VNAV-VS", 1);
		setprop("/autopilot/internal/pitch-mode", "V/S");
	}
}
}
setlistener( "/autopilot/switches/VS-button", vs_button_press, 0, 0);

var lvlchg_button_press = func {
if (getprop("/autopilot/switches/LVLCHG-button") == 1) {
	setprop("/autopilot/switches/LVLCHG-button", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);

	if (getprop("/autopilot/internal/LVLCHG") == 1) {
		setprop("/autopilot/internal/LVLCHG", 0);

	} else {
		setprop("/autopilot/internal/SPD-SPEED", 0);
		setprop("/autopilot/internal/LVLCHG", 1);
		setprop("/autopilot/internal/pitch-mode", "MCP SPD");

		alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		alt_target = getprop("/autopilot/settings/target-altitude-ft");
		if (alt < alt_target) {
			setprop("/controls/engines/engine[0]/throttle", 0.9); ## REPLACE IT WITH N1 MODE ENGAGE!!!
			setprop("/controls/engines/engine[1]/throttle", 0.9); ## REPLACE IT WITH N1 MODE ENGAGE!!!
		} else {
			setprop("/controls/engines/engine[0]/throttle", 0); ## REPLACE IT WITH RETARD MODE ENGAGE!!!
			setprop("/controls/engines/engine[1]/throttle", 0); ## REPLACE IT WITH RETARD MODE ENGAGE!!!
		}
	}
	

}
}
setlistener( "/autopilot/switches/LVLCHG-button", lvlchg_button_press, 0, 0);

var alt_acq_engage = func {
	alt_diff = getprop("/b733/helpers/alt-diff-ft");

	if (getprop("/autopilot/internal/VNAV-VS") or getprop("/autopilot/internal/LVLCHG") or getprop("/autopilot/internal/VNAV")) {
		if (alt_diff < 300) {
			setprop("/autopilot/internal/VNAV-VS", 0);
			setprop("/autopilot/internal/LVLCHG", 0);

			setprop("/autopilot/internal/VNAV-ALT-ACQ", 1);
			setprop("/autopilot/internal/pitch-mode", "ALT ACQ");
		}
	}
	if (getprop("/autopilot/internal/VNAV-ALT-ACQ")) {
		if (alt_diff < 25) {
			alt_hold_engage();
		}
	}
}
setlistener( "/b733/helpers/alt-diff-ft", alt_acq_engage, 0, 0);

var alt_hold_engage = func {
	alt_current = math.round(getprop("/autopilot/settings/target-altitude-ft"), 100);
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/settings/target-alt-hold-ft", alt_current);
	setprop("/autopilot/internal/VNAV-ALT", 1);
	setprop("/autopilot/internal/pitch-mode", "ALT HOLD");
}
