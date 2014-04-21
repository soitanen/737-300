##

##########################################################################
# Rotating VS knob
var adjust_vs_factor = func {
if (getprop("/autopilot/internal/VNAV-VS") == 1) {
	var vs_knob = getprop("/autopilot/settings/vertical-speed-knob");
	vs = vs_knob * 50;

	if (vs_knob >  20) vs = vs + (vs_knob - 20) * 50;
	if (vs_knob < -20) vs = vs + (vs_knob + 20) * 50;

	setprop ("/autopilot/settings/vertical-speed-fpm", vs);
}
if (getprop("/autopilot/internal/VNAV-VS-ARMED")) {
	settimer(vs_button_press, 0.05);
}
}

setprop("/autopilot/internal/VNAV-VS", 1);
adjust_vs_factor(); # first run to create properties
setprop("/autopilot/internal/VNAV-VS", 0);
setlistener( "/autopilot/settings/vertical-speed-knob", adjust_vs_factor, 0, 0);

##########################################################################
# VS button
var vs_button_press = func {

	setprop("/autopilot/internal/VNAV-VS-ARMED", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/display/pitch-mode-armed", "");

	var vs_fpm_current = getprop("/autopilot/internal/current-vertical-speed-fpm");

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
	setprop("/autopilot/internal/VNAV-VS", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "V/S");

	speed_engage();

	setprop("/autopilot/settings/vertical-speed-knob", vs_knob);
	settimer(adjust_vs_factor, 0.1);
}

##########################################################################
# MCP ALT change while in ALT ACQ
var mcp_alt_change = func {
	mcp_alt = getprop("/autopilot/settings/target-altitude-ft");
	diff_acq = math.abs(getprop("/autopilot/settings/alt-acq-target-alt") - mcp_alt);
	diff_hld = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft") - mcp_alt);

	if (getprop("/autopilot/internal/VNAV-ALT-ACQ") and diff_acq > 100) {
		vs_button_press();
	}
	if (getprop("/autopilot/internal/VNAV-ALT") and diff_hld > 100) {
		setprop("/autopilot/internal/VNAV-VS-ARMED", 1);
		setprop("/autopilot/display/pitch-mode-armed", "V/S");
	} else {
		setprop("/autopilot/internal/VNAV-VS-ARMED", 0);
		setprop("/autopilot/display/pitch-mode-armed", "");
	}
	setprop("/b733/sound/mcp-last-change", getprop("/sim/time/elapsed-sec"));
}
setlistener( "/autopilot/settings/target-altitude-ft", mcp_alt_change, 0, 0);

##########################################################################
# LVL CHG button
var lvlchg_button_press = func {

	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV-VS-ARMED", 0);

	if (getprop("/autopilot/internal/LVLCHG") == 1) {
		setprop("/autopilot/internal/LVLCHG", 0);

	} else {
		setprop("/autopilot/internal/SPD-SPEED", 0);
		setprop("/autopilot/internal/LVLCHG", 1);

		setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/pitch-mode", "MCP SPD");

		alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		alt_target = getprop("/autopilot/settings/target-altitude-ft");
		if (alt < alt_target) {
			n1_engage();
			setprop("/autopilot/settings/min-lvlchg-vs", 0);
			setprop("/autopilot/settings/max-lvlchg-vs", 6000);
		} else {
			retard_engage();
			setprop("/autopilot/settings/min-lvlchg-vs", -7800);
			setprop("/autopilot/settings/max-lvlchg-vs", 0);
		}
	}
}

##########################################################################
# Changeover button
var changeover_button_press = func {

	a = getprop("/fdm/jsbsim/atmosphere/a-fps");
	ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
	if ( ias == nil ) ias = 0.001;
	if ( ias < 1 ) ias = 100;
	tas = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
	if ( tas == nil ) tas = 0.001;
	if ( tas == 0 ) tas = 0.001;

	if (getprop("/autopilot/internal/SPD-IAS")) {
		target_ias = getprop("/autopilot/settings/target-speed-kt");
		target_mach = math.round((target_ias * tas/ias) / ( a * 0.5924838012959), 0.01);
		if (target_mach > 0.89) target_mach = 0.89;
		if (target_mach < 0.60) target_mach = 0.60;
		setprop("/autopilot/settings/target-speed-mach", target_mach);

		setprop("/autopilot/internal/SPD-IAS", 0);
		setprop("/autopilot/internal/SPD-MACH", 1);
	} else {
		target_mach = getprop("/autopilot/settings/target-speed-mach");
		target_ias = math.round((target_mach * ias * a * 0.5924838012959) / tas, 1);
		if (target_ias > 399) target_ias = 399;
		if (target_ias < 110) target_ias = 110;
		setprop("/autopilot/settings/target-speed-kt", target_ias);

		setprop("/autopilot/internal/SPD-MACH", 0);
		setprop("/autopilot/internal/SPD-IAS", 1);
	}
}

##########################################################################
# SPEED knob behaviour
var speed_increase = func {
	if (getprop("/autopilot/internal/SPD-IAS")) {
		target_ias = getprop("/autopilot/settings/target-speed-kt");
		target_ias = target_ias + 1;
		if (target_ias > 399) target_ias = 399;
		setprop("/autopilot/settings/target-speed-kt", target_ias);
	} else {
		target_mach = getprop("/autopilot/settings/target-speed-mach");
		target_mach = target_mach + 0.01;
		if (target_mach > 0.89) target_mach = 0.89;
		setprop("/autopilot/settings/target-speed-mach", target_mach);
	}
}
var speed_decrease = func {
	if (getprop("/autopilot/internal/SPD-IAS")) {
		target_ias = getprop("/autopilot/settings/target-speed-kt");
		target_ias = target_ias - 1;
		if (target_ias < 110) target_ias = 110;
		setprop("/autopilot/settings/target-speed-kt", target_ias);
	} else {
		target_mach = getprop("/autopilot/settings/target-speed-mach");
		target_mach = target_mach - 0.01;
		if (target_mach < 0.60) target_mach = 0.60;
		setprop("/autopilot/settings/target-speed-mach", target_mach);
	}
}
##########################################################################
# N1 button
var n1_button_press = func {
	if (getprop("/autopilot/internal/SPD-N1")) {
		setprop("/autopilot/internal/SPD-N1", 0);
	} else {
		n1_engage();
	}
}

var n1_engage = func {
	if (getprop("/autopilot/internal/TOGA")) {
		mcp_speed = getprop("/autopilot/settings/target-speed-kt");
		setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
	}

	setprop("/autopilot/internal/SPD-SPEED", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/SPD-RETARD", 0);
	setprop("/autopilot/internal/SPD-N1", 1);
	setprop("/autopilot/internal/target-n1", 95);

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "N1");
}
##########################################################################
# SPEED button
var speed_button_press = func {
	if (getprop("/autopilot/internal/SPD-SPEED")) {
		setprop("/autopilot/internal/SPD-SPEED", 0);
	} else {
		speed_engage();
	}

}

##########################################################################
# Engaging SPEED mode
var speed_engage = func {
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/SPD-RETARD", 0);
	setprop("/autopilot/internal/SPD-SPEED", 1);

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "MCP SPD");
}

##########################################################################
# Engaging RETARD mode
var retard_engage = func {
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/SPD-SPEED", 0);
	setprop("/autopilot/internal/SPD-RETARD", 1);

	setprop("/autopilot/internal/target-n1", 22);

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "RETARD");
}

var retard_check = func {
	retard = getprop("/autopilot/internal/SPD-RETARD");
	if (retard) {
		if (getprop("/autopilot/internal/servo-throttle[0]") < 0.01) {
			setprop("/autopilot/internal/SPD-RETARD", 0);

			setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/throttle-mode", "ARM");
		}
		settimer(retard_check, 0.2);
	}
}
setlistener( "/autopilot/internal/SPD-RETARD", retard_check, 0, 0);

##########################################################################
# VNAV button
var vnav_button_press = func {

}

##########################################################################
# ALT HOLD button
var althld_button_press = func {

	GS = getprop("/autopilot/internal/VNAV-GS");

	if (!GS) {
		setprop("/autopilot/internal/max-vs-fpm", 2000);
		setprop("/autopilot/internal/min-vs-fpm", -2000);

		alt_hold_engage();
	}
}

##########################################################################
# ALT HOLD button light switch
var alt_hold_light = func {
	mcp_alt = getprop("/autopilot/settings/target-altitude-ft");
	diff_hld = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft") - mcp_alt);
	alt_hld = getprop("/autopilot/internal/VNAV-ALT");

	if (alt_hld and diff_hld > 50) {
		setprop("/autopilot/internal/VNAV-ALT-light", 1);
	} else {
		setprop("/autopilot/internal/VNAV-ALT-light", 0);
	}

	if (alt_hld) settimer(alt_hold_light, 0.5);
}
setlistener( "/autopilot/internal/VNAV-ALT", alt_hold_light, 0, 0);

##########################################################################
# APP button
var app_button_press = func {

	GS  = getprop("/autopilot/internal/VNAV-GS");
	LOC = getprop("/autopilot/internal/LNAV-NAV");
	if (!GS) {
		setprop("/autopilot/internal/VNAV-GS-armed", 1);
		setprop("/autopilot/display/pitch-mode-armed", "GS");
		if (!LOC) {
			setprop("/autopilot/internal/LNAV-NAV-armed", 1);
			setprop("/autopilot/display/roll-mode-armed", "VOR/LOC");
		}
	}
}

##########################################################################
# LNAV button
var lnav_button_press = func {
	route_active = getprop("/autopilot/route-manager/active");
	GS = getprop("/autopilot/internal/VNAV-GS");
	crosstrack = getprop("/instrumentation/gps/wp/wp[1]/course-error-nm");

	if (!GS and route_active) {
		if (math.abs(crosstrack) < 3) {
			setprop("/autopilot/internal/LNAV-NAV-armed", 0);
			setprop("/autopilot/display/roll-mode-armed", "");

			setprop("/autopilot/internal/LNAV-NAV", 0);
			setprop("/autopilot/internal/LNAV-HDG", 0);
			setprop("/autopilot/internal/LNAV", 1);

			setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/roll-mode", "LNAV");
		}
	}
}

##########################################################################
# HDG button
var hdg_button_press = func {

	GS  = getprop("/autopilot/internal/VNAV-GS");
	if (!GS) {
		hdg_mode_engage();
	}
}

##########################################################################
# VORLOC button
var vorloc_button_press = func {

	GS  = getprop("/autopilot/internal/VNAV-GS");
	if (!GS) {
		setprop("/autopilot/internal/LNAV-NAV-armed", 1);
		setprop("/autopilot/display/roll-mode-armed", "VOR/LOC");
	}
}

##########################################################################
# CMDA button
var cmda_button_press = func {

	ailerons = getprop("/controls/flight/aileron");
	elevator = getprop("/controls/flight/elevator");
	if (ailerons < 0.15 and ailerons > -0.15 and elevator < 0.15 and elevator > -0.15) {
		setprop("/autopilot/internal/CMDA", 1);
		setprop("/autopilot/internal/CMDB", 0);
		if (getprop("/autopilot/internal/TOGA")) {
			mcp_speed = getprop("/autopilot/settings/target-speed-kt");
			setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
		}
	}
}

##########################################################################
# CMDB button
var cmdb_button_press = func {

	ailerons = getprop("/controls/flight/aileron");
	elevator = getprop("/controls/flight/elevator");
	if (ailerons < 0.15 and ailerons > -0.15 and elevator < 0.15 and elevator > -0.15) {
		setprop("/autopilot/internal/CMDA", 0);
		setprop("/autopilot/internal/CMDB", 1);
		if (getprop("/autopilot/internal/TOGA")) {
			mcp_speed = getprop("/autopilot/settings/target-speed-kt");
			setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
		}
	}
}

##########################################################################
# CWSA button
var cwsa_button_press = func {

}

##########################################################################
# CWSB button
var cwsb_button_press = func {

}

##########################################################################
# APDSNG button
var apdsng_button_press = func {

}

##########################################################################
##########################################################################
# Engaging ALT ACQ mode
var alt_acq_engage = func {
	if (getprop("/autopilot/internal/VNAV-VS") or getprop("/autopilot/internal/LVLCHG") or getprop("/autopilot/internal/VNAV")) {
		alt_diff = getprop("/b733/helpers/alt-diff-ft");
		current_vs = getprop("/autopilot/settings/vertical-speed-fpm");
		possible_engage_alt =  math.abs(current_vs * 0.15);


		if (alt_diff < 300 or alt_diff < possible_engage_alt) {
			setprop("/autopilot/internal/VNAV-VS", 0);
			setprop("/autopilot/internal/LVLCHG", 0);
			setprop("/autopilot/internal/TOGA", 0);

			setprop("/autopilot/internal/VNAV-ALT-ACQ", 1);
			setprop("/autopilot/settings/alt-acq-target-alt", getprop("/autopilot/settings/target-altitude-ft"));

			setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/pitch-mode", "ALT ACQ");

			speed_engage();
			if (current_vs > 0) {
				setprop("/autopilot/internal/max-vs-fpm", current_vs);
				setprop("/autopilot/internal/min-vs-fpm", -300);
			} else {
				setprop("/autopilot/internal/max-vs-fpm", 300);
				setprop("/autopilot/internal/min-vs-fpm", current_vs);
			}
		}
	}
	if (getprop("/autopilot/internal/VNAV-ALT-ACQ")) {
		if (getprop("/b733/helpers/alt-diff-ft") < 5) {
			alt_hold_engage();
		}
	}
}
setlistener( "/b733/helpers/alt-diff-ft", alt_acq_engage, 0, 0);

##########################################################################
# Engaging ALT HOLD mode
var alt_hold_engage = func {
	alt_current = getprop("/instrumentation/altimeter/pressure-alt-ft");
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/settings/target-alt-hold-ft", alt_current);
	setprop("/autopilot/internal/VNAV-ALT", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "ALT HOLD");

	speed_engage();
}


##########################################################################
# Engaging HDG SEL mode
var hdg_mode_engage = func {
	setprop("/autopilot/internal/LNAV", 0);
	setprop("/autopilot/internal/LNAV-NAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "HDG SEL");
}

##########################################################################
# Armed VOR/LOC mode behaviour
var vorloc_armed = func {
if (getprop("/autopilot/internal/LNAV-NAV-armed")) {

	deflection = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
	course = getprop("/instrumentation/nav[0]/radials/target-radial-deg");
	delta_target_heading = getprop("/autopilot/internal/target-heading-shift-nav1");
	delta_current_heading = geo.normdeg180(getprop("/orientation/heading-deg") - course);

	if((deflection < 0.2 and deflection > -0.2) or (deflection < 0.99 and deflection > -0.99 and math.abs(delta_target_heading) < math.abs(delta_current_heading))){
		vorloc_mode_engage();
	}

	settimer(vorloc_armed, 0.5);
}
}

setlistener( "/autopilot/internal/LNAV-NAV-armed", vorloc_armed, 0, 0);

##########################################################################
# Armed GS mode behaviour
var app_armed = func {
if (getprop("/autopilot/internal/VNAV-GS-armed")) {
	deflection = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
	in_range = getprop("/instrumentation/nav[0]/gs-in-range");
	LOC = getprop("/autopilot/internal/LNAV-NAV");
	if(deflection < 0.2 and deflection > -0.2 and LOC and in_range){
		gs_engage();
	}

	settimer(app_armed, 0.5);
}
}

setlistener( "/autopilot/internal/VNAV-GS-armed", app_armed, 0, 0);

##########################################################################
# Engaging VOR/LOC mode
var vorloc_mode_engage = func {
	setprop("/autopilot/internal/LNAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 0);
	setprop("/autopilot/internal/LNAV-NAV", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "VOR/LOC");
	setprop("/autopilot/display/roll-mode-armed", "");
	setprop("/autopilot/internal/LNAV-NAV-armed", 0);
}

##########################################################################
# Engaging GLIDESLOPE	 mode
var gs_engage = func {
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/VNAV-GS", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "GS");
	setprop("/autopilot/display/pitch-mode-armed", "");
	setprop("/autopilot/internal/VNAV-GS-armed", 0);

	speed_engage();
}

##########################################################################
# Engaging TOGA	mode
var toga_engage = func {
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 0);
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/SPD-SPEED", 0);
	setprop("/autopilot/internal/TOGA", 1);
	setprop("/autopilot/internal/target-n1", 106);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/toga-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "TO/GA");
	setprop("/autopilot/display/pitch-mode-armed", "");
	setprop("/autopilot/internal/VNAV-GS-armed", 0);

}

##########################################################################
# Calculating turn anticipation distance
var turn_anticipate = func {
if (getprop("/autopilot/internal/LNAV")){
	gnds_mps = getprop("/instrumentation/gps/indicated-ground-speed-kt") * 0.5144444444444;
	current_course = getprop("/instrumentation/gps/wp/leg-true-course-deg");
	wp_fly_to = getprop("/autopilot/route-manager/current-wp");
	if (wp_fly_to < 0) wp_fly_to = 0;
	next_course = getprop("/autopilot/route-manager/route/wp["~wp_fly_to~"]/leg-bearing-true-deg");
	max_bank_limit = getprop("/autopilot/settings/maximum-bank-limit");

	delta_angle = math.abs(geo.normdeg180(current_course - next_course));
	max_bank = delta_angle * 1.5;
	if (max_bank > max_bank_limit) max_bank = max_bank_limit;
	radius = (gnds_mps * gnds_mps) / (9.81 * math.tan(max_bank/57.2957795131));
	time = 0.64 * gnds_mps * delta_angle * 0.7 / (360 * math.tan(max_bank/57.2957795131));
	delta_angle_rad = (180 - delta_angle) / 114.5915590262;
	R = radius/math.sin(delta_angle_rad);
	turn_dist = math.cos(delta_angle_rad) * R * 1.5 / 1852;

	setprop("/instrumentation/gps/config/over-flight-distance-nm", turn_dist);
	if (getprop("/sim/time/elapsed-sec")-getprop("/autopilot/internal/wp-change-time") > 60) {
		setprop("/autopilot/internal/wp-change-check-period", time);
	}

	settimer(turn_anticipate, 5);
}
}
setlistener("/autopilot/internal/LNAV", turn_anticipate, 0, 0);

var wp_change = func {
	setprop("/autopilot/internal/wp-change-time", getprop("/sim/time/elapsed-sec"));

}
setlistener("/autopilot/route-manager/current-wp", wp_change, 0, 0);
##########################################################################
##########################################################################
# Rectangles for mode change
var roll_mode_change = func {
	last_change = getprop("/autopilot/display/roll-mode-last-change");
	current_time = getprop("/sim/time/elapsed-sec");
	period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/roll-mode-rectangle", 1);
		settimer(roll_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/roll-mode-rectangle", 0);
	}
}
var pitch_mode_change = func {
	last_change = getprop("/autopilot/display/pitch-mode-last-change");
	current_time = getprop("/sim/time/elapsed-sec");
	period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/pitch-mode-rectangle", 1);
		settimer(pitch_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/pitch-mode-rectangle", 0);
	}
}
var throttle_mode_change = func {
	last_change = getprop("/autopilot/display/throttle-mode-last-change");
	current_time = getprop("/sim/time/elapsed-sec");
	period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/throttle-mode-rectangle", 1);
		settimer(throttle_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/throttle-mode-rectangle", 0);
	}
}
setlistener( "/autopilot/display/roll-mode", roll_mode_change, 0, 0);
setlistener( "/autopilot/display/pitch-mode", pitch_mode_change, 0, 0);
setlistener( "/autopilot/display/throttle-mode", throttle_mode_change, 0, 0);
