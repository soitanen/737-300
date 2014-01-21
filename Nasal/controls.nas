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

  settimer( trim_handler, 0 );
}

setprop( "b733/controls/trim/elevator-cmd-dummy", 0 );
trim_handler();

