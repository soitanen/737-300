

sbvalve = func {
  # Check if Auto Speedbrakes are Armed
  AutoSB = getprop("/controls/flight/autospeedbrakes-armed");

    if (AutoSB == 1) {  

		    APIASEngaged = getprop("/autopilot/locks/speed");
            if (APIASEngaged == "speed-with-throttle") {
            # Too Fast or Too Slow in AIS mode
                if (getprop("/velocities/airspeed-kt") > getprop("/autopilot/settings/target-speed-kt") +5) {
				            setprop("/controls/flight/speedbrake", getprop("/controls/flight/speedbrake") + 0.05);
                } else if (getprop("/velocities/airspeed-kt") < getprop("/autopilot/settings/target-speed-kt") -5) {
				            setprop("/controls/flight/speedbrake", getprop("/controls/flight/speedbrake") - 0.05);
	              } else { 
	  		            setprop("/controls/flight/speedbrake", 0.0);
				        }
				        #End of Too Fast or Too Slow in IAS Mode
			      } 
			      #End of are we in IAS Mode		

		    APMachEngaged = getprop("/autopilot/locks/speed");
            if (APMachEngaged == "mach-with-throttle") {
            # Too Fast or Too Slow in Mach mode
                if (getprop("/velocities/mach") > getprop("/autopilot/settings/target-speed-mach") +.01) {
				            setprop("/controls/flight/speedbrake", getprop("/controls/flight/speedbrake") + 0.07);
                } else if (getprop("/velocities/mach") < getprop("/autopilot/settings/target-speed-mach") - 0.07) {
				            setprop("/controls/flight/speedbrake", getprop("/controls/flight/speedbrake") - 0.05);
	              } else { 
	  		            setprop("/controls/flight/speedbrake", 0.0);
				        }
				        #End of Too Fast or Too Slow in Mach Mode
			      } 
			      #End of are we in Mach mode		

						
				#Disengage Auto-SpeedBrakes if A/P NOT in any Speed mode, throttle advanced and Reversers NOT deployed
		    APSpeedEngaged = getprop("/autopilot/locks/speed");
            if (APSpeedEngaged == "") {
						  if (getprop("/controls/engines/engine[0]/throttle") > 0.5) {
						    if (getprop("/controls/engines/engine[0]/reverser") == 0) { 						
						      setprop("/controls/flight/speedbrake", 0.0);
								}
							}
						}
						#End of NOT in any speed mode
						
	  } 
		#End of if AutoSB Armed
 
    settimer(sbvalve, 0.5);   
} 
# End of sbvalve
 
init = func {
   settimer(sbvalve, 0.5);
}

init();
