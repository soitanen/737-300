##

var help_win = screen.window.new( 0, 0, 1, 3 );
help_win.fg = [0,1,1,1];

var throttle_round = func {

   at_pos = math.round(getprop("/autopilot/internal/servo-throttle[0]")*100, 1);
   mt_pos = math.round(getprop("/controls/engines/engine[0]/throttle")*100, 1);

   setprop("/b733/helpers/at-pos-round", at_pos);
   setprop("/b733/helpers/mt-pos-round", mt_pos);

}

var throttle_info = func {
if (getprop("/b733/at-helper")) {
  at = getprop("/autopilot/internal/SPD");
  speed = getprop("/autopilot/internal/SPD-SPEED");
  n1 = getprop("/autopilot/internal/SPD-N1");
  toga = getprop("/autopilot/internal/TOGA");
  retard = getprop("/autopilot/internal/SPD-RETARD");

  if (at and (speed or n1 or toga or retard)) {
   at_pos = getprop("/b733/helpers/at-pos-round");
   mt_pos = getprop("/b733/helpers/mt-pos-round");


   help_win.write(sprintf("AT %.0f%% : %.0f%% MT", at_pos, mt_pos) );
  }
}
}

setlistener( "/autopilot/internal/servo-throttle[0]", throttle_round, 0, 0 );
setlistener( "/controls/engines/engine[0]/throttle", throttle_round, 0, 0 );

setlistener( "/b733/helpers/at-pos-round", throttle_info, 0, 0 );
setlistener( "/b733/helpers/mt-pos-round", throttle_info, 0, 0 );

var messenger = func{
help_win.write(arg[0]);
}
print("Help subsystem started");
