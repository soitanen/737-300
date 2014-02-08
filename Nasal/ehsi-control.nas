##
var mode_change = func(i) {
	var mode = getprop("/b733/controls/ehsi["~i~"]/mode-selector");
	var ils = getprop("/instrumentation/nav/nav-loc");

	NAV_MODE = "VOR";
	if (ils == 1) NAV_MODE = "APP";

	if (mode == 1) {
		setprop("/instrumentation/efis["~i~"]/inputs/nd-centered", 1);
		setprop("/instrumentation/efis["~i~"]/mfd/display-mode", NAV_MODE);
	} elsif (mode == 2) {
		setprop("/instrumentation/efis["~i~"]/inputs/nd-centered", 0);
		setprop("/instrumentation/efis["~i~"]/mfd/display-mode", NAV_MODE);
	} elsif (mode == 3) {
		setprop("/instrumentation/efis["~i~"]/inputs/nd-centered", 0);
		setprop("/instrumentation/efis["~i~"]/mfd/display-mode", "MAP");
	} elsif (mode == 4) {
		setprop("/instrumentation/efis["~i~"]/inputs/nd-centered", 1);
		setprop("/instrumentation/efis["~i~"]/mfd/display-mode", "MAP");
	} elsif (mode == 5) {
		setprop("/instrumentation/efis["~i~"]/inputs/nd-centered", 1);
		setprop("/instrumentation/efis["~i~"]/mfd/display-mode", "PLAN");
	}
}

setlistener( "/b733/controls/ehsi[0]/mode-selector", func {mode_change(0);}, 0, 0);
setlistener( "/b733/controls/ehsi[1]/mode-selector", func {mode_change(1);}, 0, 0);
setlistener( "/instrumentation/nav/nav-loc", func {mode_change(0);}, 0, 0);
setlistener( "/instrumentation/nav/nav-loc", func {mode_change(1);}, 0, 0);
