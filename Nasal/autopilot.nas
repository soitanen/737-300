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
	}
	

}
}
setlistener( "/autopilot/switches/VS-button", vs_button_press, 0, 0);
