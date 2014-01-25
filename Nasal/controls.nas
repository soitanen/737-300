var TRIM_RATE = 0.01;

var trim_handler = func{
  var old_trim = num( getprop("b733/controls/trim/elevator-old-trim") );
  if ( old_trim == nil ) old_trim = 0.0;
  var new_trim = num( getprop("/controls/flight/elevator-trim") );
  if ( new_trim == nil ) new_trim = 0.0;

  var ap_a_on = getprop("/autopilot/internal/CMDA");
  var ap_b_on = getprop("/autopilot/internal/CMDB");

  var delta = old_trim - new_trim;
  #DEBUG setprop( "b733/controls/trim/elevator-delta", delta );
  setprop( "b733/controls/trim/elevator-old-trim", new_trim );
  if( delta > 0.0 ) interpolate( "b733/controls/trim/elevator-cmd-dummy", 1, 0.2 );
  if( delta == 0.0 ) interpolate( "b733/controls/trim/elevator-cmd-dummy", 0, 0.02 );
  if( delta < 0.0 ) interpolate( "b733/controls/trim/elevator-cmd-dummy", -1, 0.2 );
  var dummy = num( getprop("b733/controls/trim/elevator-cmd-dummy") );
  if( dummy > 0.01 ) {
    var stab_cmd = 1;
    #setprop( "b733/controls/trim/elevator-cmd", 1 );
  } elsif( dummy < -0.01 ) {
    var stab_cmd = -1;
    #setprop( "b733/controls/trim/elevator-cmd", -1 );
  } else {
    var stab_cmd = 0;
    #setprop( "b733/controls/trim/elevator-cmd", 0 );
  }

  var stab_pos = num( getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
  if ( stab_pos == nil ) stab_pos = 3.0;
  var flaps_pos = num( getprop("/fdm/jsbsim/fcs/flap-pos-norm") );
  if ( flaps_pos == nil ) flaps_pos = 0.0;

  var trim_speed = 0.615;                                                    #Fastest with flaps extended and manual control
  if (flaps_pos == 0 and !ap_a_on and !ap_b_on) trim_speed = trim_speed / 3; #With flaps retracted and AP off
  if (flaps_pos > 0 and (ap_a_on or ap_b_on)) trim_speed = trim_speed / 3;   #With flaps extended and AP on
  if (flaps_pos == 0 and (ap_a_on or ap_b_on)) trim_speed = trim_speed / 6;  #With flaps retracted and AP on

  controls.slewProp ("/fdm/jsbsim/fcs/stabilizer-pos-unit", trim_speed * stab_cmd );

  if (stab_pos > 12.5 and stab_cmd == 1 and !ap_a_on and !ap_b_on) setprop( "/fdm/jsbsim/fcs/stabilizer-pos-unit", stab_pos );
  if (stab_pos > 14 and stab_cmd == 1 and (ap_a_on or ap_b_on)) setprop( "/fdm/jsbsim/fcs/stabilizer-pos-unit", stab_pos );
  if (stab_pos < 2.5 and stab_cmd == -1 and !ap_a_on and !ap_b_on and flaps_pos > 0) setprop( "/fdm/jsbsim/fcs/stabilizer-pos-unit", stab_pos );
  if (stab_pos < 0.25 and stab_cmd == -1 and !ap_a_on and !ap_b_on and flaps_pos == 0) setprop( "/fdm/jsbsim/fcs/stabilizer-pos-unit", stab_pos );

  var sound = stab_pos * 952.94 / 360;
  while (sound > 1) sound -= 1;
  if (sound > 0.9 or sound < 0.1) setprop("/b733/sound/stab-trim", 0);
  if (sound < 0.9 and sound > 0.1) setprop("/b733/sound/stab-trim", 1);

  settimer( trim_handler, 0 );
}

setprop( "b733/controls/trim/elevator-cmd-dummy", 0 );
trim_handler();

var spoilers_control = func {
  var lever_pos = num( getprop("b733/controls/flight/spoilers-lever-pos") );

  if (lever_pos == 0) {
    setprop( "/controls/flight/speedbrake", 0.00 );
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers DOWN!");
  }
  if (lever_pos == 1) {
    setprop( "/controls/flight/speedbrake", 0.00 );
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers ARMED!");
  }
  if (lever_pos == 2) setprop( "/controls/flight/speedbrake", 0.1625 );
  if (lever_pos == 3) {
    setprop( "/controls/flight/speedbrake", 0.325 );
    setprop( "/controls/flight/spoilers", 0 );
  }
  if (lever_pos == 4) {
    setprop( "/controls/flight/speedbrake", 0.4875 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
  if (lever_pos == 5) {
    setprop( "/controls/flight/speedbrake", 0.65 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    if (getprop("/sim/messages/copilot") == "Spoilers at FLIGHT DETENT!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers at FLIGHT DETENT!");}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
  if (lever_pos == 6) {
    setprop( "/controls/flight/speedbrake", 1.00 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    if (getprop("/sim/messages/copilot") == "Spoilers UP!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers UP!");}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
}

setlistener( "/b733/controls/flight/spoilers-lever-pos", spoilers_control, 0, 0 );

var landing_check = func{
	var air_ground = getprop("/b733/sensors/air-ground");
	var spin_up = getprop("/b733/sensors/main-gear-spin");
	var was_ia = getprop("/b733/sensors/was-in-air");
	var lever_pos = num( getprop("b733/controls/flight/spoilers-lever-pos") );
	var throttle_1 = getprop("/controls/engines/engine[0]/throttle");
	var throttle_2 = getprop("/controls/engines/engine[1]/throttle");
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("b733/controls/gear/autobrake-used");

	if ((air_ground == "ground" or spin_up) and was_ia and throttle_1 < 0.05 and throttle_2 < 0.05) { #normal landing
		if (lever_pos == 1) setprop("b733/controls/flight/spoilers-lever-pos", 6);
		if (!ab_used) {
			if (ab_pos == 1) {
				setprop("/controls/gear/brake-left", 0.2);
				setprop("/controls/gear/brake-right", 0.2);
			} elsif (ab_pos == 2) {
				setprop("/controls/gear/brake-left", 0.4);
				setprop("/controls/gear/brake-right", 0.4);
			} elsif (ab_pos == 3) {
				setprop("/controls/gear/brake-left", 0.6);
				setprop("/controls/gear/brake-right", 0.6);
			} elsif (ab_pos == 4) {
				setprop("/controls/gear/brake-left", 0.8);
				setprop("/controls/gear/brake-right", 0.8);
			}
			setprop("b733/controls/gear/autobrake-used", 1);
		}
	} elsif (air_ground == "ground" and !was_ia and spin_up and throttle_1 < 0.05 and throttle_2 < 0.05 and ab_pos == 5) { #Rejected take-off
		var GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593; 
		if (lever_pos == 0) setprop("b733/controls/flight/spoilers-lever-pos", 6);

		var ab_used = getprop("b733/controls/gear/autobrake-used");
		if (!ab_used) {
			if (GROUNDSPEED > 84) {
				setprop("/controls/gear/brake-left", 1);
				setprop("/controls/gear/brake-right", 1);
			}
			setprop("b733/controls/gear/autobrake-used", 1);
		}
	}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;

    settimer(landing_check, time);
}
landing_check();


var ab_reset = func{
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("b733/controls/gear/autobrake-used");

	if (ab_pos == 0 and ab_used) setprop("b733/controls/gear/autobrake-used", 0);

}
setlistener( "/controls/gear/autobrakes", ab_reset, 0, 0);

