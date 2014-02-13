##

var adjust_vs_factor = func {
	var vs = getprop("/autopilot/settings/vertical-speed-fpm");

	if ( vs > -1050 and vs < 1000 ) {
		setprop ("/b733/helpers/vs-increase-factor", 50);
	} else {
		setprop ("/b733/helpers/vs-increase-factor", 100);
	}

	if ( vs > -1000 and vs < 1050 ) {
		setprop ("/b733/helpers/vs-decrease-factor", 50);
	} else {
		setprop ("/b733/helpers/vs-decrease-factor", 100);
	}
}

adjust_vs_factor(); # first run to create properties
setlistener( "/autopilot/settings/vertical-speed-fpm", adjust_vs_factor, 0, 0);

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
		setprop("/autopilot/settings/vertical-speed-fpm", vs_fpm_current);
		setprop("/autopilot/internal/VNAV-VS", 1);
	}
	

}
}
setlistener( "/autopilot/switches/VS-button", vs_button_press, 0, 0);
