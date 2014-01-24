# Controls systems that depend on the air-ground sensor
# (also called "squat-switch") position.  This assumes
# the airplane always starts on the ground (just like the
# real airplane).
#

INAIR = "false";
REJECT = "false";
LANDED = "false";

call_airground = func {
   WOW = getprop("/gear/gear/wow");
   GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593;  
 
   if (WOW == 1) {
      # nose gear strut is compressed

     if (INAIR == "false") {
             
        if ((getprop("/controls/gear/autobrakes") == 5) and (REJECT=="false")) {
          if (getprop("/controls/engines/engine[0]/throttle") < 0.1) { 
            if (GROUNDSPEED > 60.0) {
              REJECT = "true";
              print ("Rejecting Takeoff at ", GROUNDSPEED, " kts ground speed");
							gui.popupTip("Rejecting Takeoff at " ~ int(GROUNDSPEED) ~ " kts ground speed",10);
            }
          }
        }

        if (REJECT == "true") {
          if (GROUNDSPEED < 2.0) {
            REJECT = "false";
            setprop("/controls/gear/autobrakes", 5);
            setprop("/controls/gear/brake-left", 0.0);
            setprop("/controls/gear/brake-right", 0.0);
						setprop("/controls/flight/speedbrake", 0.0);
            setprop("/controls/flight/spoilers", 0.0);
						#setprop("/controls/flight/autospeedbrakes-armed", 1);
          } else {
            setprop("/controls/gear/brake-left", 1.0);
            setprop("/controls/gear/brake-right", 1.0);
            setprop("/controls/flight/speedbrake", 1.0);
            setprop("/controls/flight/spoilers", 1.0);
          } 
        }

        if (LANDED == "true") {
	        if (GROUNDSPEED < 130.0){
            #Go-Aound
            if (getprop("/controls/engines/engine[0]/throttle") > 0.5) {
						  if (getprop("/controls/engines/engine[0]/reverser") == 0) { 
               LANDED = "false";
               setprop("/controls/flight/speedbrake", 0.0);
               setprop("/controls/flight/spoilers", 0.0);
               #setprop("/controls/gear/autobrakes", 0);
               setprop("/controls/gear/brake-left", 0.0);
               setprop("/controls/gear/brake-right", 0.0);
             }
					 }
           if (GROUNDSPEED < 30.0) {
            LANDED = "false";
						setprop("/controls/flight/speedbrake", 0.0);
	  			  setprop("/controls/flight/spoilers", 0.0);
            setprop("/controls/gear/autobrakes", 5);
            setprop("/controls/gear/brake-left", 0.0);
            setprop("/controls/gear/brake-right", 0.0);
	  			  #setprop("/controls/flight/autospeedbrakes-armed", 1);
           }
         }
       }	
     } else {
       # we have touched down
       INAIR = "false";
       LANDED = "true";

        var SETTING = getprop("/controls/gear/autobrakes");

        if (SETTING == 0) {
          # autobrakes are off, so do nothing here
        }
        elsif (SETTING == 1) {
      	  #if (getprop("/controls/flight/autospeedbrakes-armed") == 1) {
            # autobrakes set to level 1
            setprop("/controls/gear/brake-left", 0.2);
            setprop("/controls/gear/brake-right", 0.2);
	  			  setprop("/controls/flight/speedbrake", 1.0);
	  			  setprop("/controls/flight/spoilers", 1.0);
	  			  #setprop("/controls/flight/autospeedbrakes-armed", 0);
          #}
	      }
        elsif (SETTING == 2) {
	        #if (getprop("/controls/flight/autospeedbrakes-armed") == 1) {
            # autobrakes set to level 2
            setprop("/controls/gear/brake-left", 0.4);
            setprop("/controls/gear/brake-right", 0.4);
	  			  setprop("/controls/flight/speedbrake", 1.0);
	  			  setprop("/controls/flight/spoilers", 1.0);
	  			  #setprop("/controls/flight/autospeedbrakes-armed", 0);
         # }
	      }
        elsif (SETTING == 3) {
	       # if (getprop("/controls/flight/autospeedbrakes-armed") == 1) {
            # autobrakes set to level 3
            setprop("/controls/gear/brake-left", 0.8);
            setprop("/controls/gear/brake-right", 0.8);
	  			  setprop("/controls/flight/speedbrake", 1.0);
	  			  setprop("/controls/flight/spoilers", 1.0);
	  			  #setprop("/controls/flight/autospeedbrakes-armed", 0);
          #}
	      }
        elsif (SETTING == 4) {
	        #if (getprop("/controls/flight/autospeedbrakes-armed") == 1) {
            # autobrakes set to level MAX
            setprop("/controls/gear/brake-left", 1.0);
            setprop("/controls/gear/brake-right", 1.0);
	  			  setprop("/controls/flight/speedbrake", 1.0);
	  			  setprop("/controls/flight/spoilers", 1.0);
	  			  setprop("/controls/flight/autospeedbrakes-armed", 0);         
         # } 
        }
        else {
          # autobrakes mistakenly set to wrong value
          setprop("/controls/gear/autobrakes", 0);
        }
      }

   } else {
      # nose gear is not compressed
      INAIR = "true";
			if (getprop("/controls/gear/autobrakes") == 5) {
				setprop("/controls/gear/autobrakes", 0.0);
			}
      LANDED = "false";
   }

   # schedule the next call
   settimer(call_airground, 0.2);   
}
 
init = func {
   settimer(call_airground, 0.0);
}

#init();

var air_ground = func {
	var wow_nose = getprop("/gear/gear/wow");
	var wow_right = getprop("/gear/gear[2]/wow");
	var height = getprop("/position/altitude-agl-ft");

	if (wow_nose and wow_right) {
		setprop("/b733/sensors/air-ground", "ground");
	} else {
		setprop("/b733/sensors/air-ground", "air");
	}
	
	var time = height / 70;
	if (time < 0.2 or time > 600) time = 0.2;

	settimer(air_ground, time);
}

air_ground();


var main_wheel_spin = func {
	var speed_left = getprop("/fdm/jsbsim/gear/unit[1]/wheel-speed-fps") * 0.5924;
	var speed_right = getprop("/fdm/jsbsim/gear/unit[2]/wheel-speed-fps") * 0.5924;
	var height = getprop("/position/altitude-agl-ft");

	if (speed_left > 60 or speed_right > 60) {
		setprop("/b733/sensors/main-gear-spin", "true");
	} else {
		setprop("/b733/sensors/main-gear-spin", "false");
	}

	var time = height / 70;
	if (time < 0.2 or time > 600) time = 0.2;

	settimer(main_wheel_spin, time);
}

main_wheel_spin();

var was_in_air = func{
	var air_ground = getprop("/b733/sensors/air-ground");
	var was_ia = getprop("/b733/sensors/was-in-air");
	var GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593; 

	if (air_ground == "air" and !was_ia) setprop("/b733/sensors/was-in-air", "true");
	if (air_ground == "air" and was_ia) setprop("/b733/sensors/was-in-air", "true");
	if (air_ground == "ground" and !was_ia) setprop("/b733/sensors/was-in-air", "false");
	if (air_ground == "ground" and was_ia) {
		if (GROUNDSPEED < 60){
			setprop("/b733/sensors/was-in-air", "false");
		} else {
			settimer (was_in_air, 0.5);
		}
	}
}
setlistener( "/b733/sensors/air-ground", was_in_air, 0, 0);
  
