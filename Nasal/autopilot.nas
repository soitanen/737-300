##

var adjust_vs_factor =func {
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
