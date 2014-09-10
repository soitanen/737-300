##
setlistener("/sim/signals/fdm-initialized", func {
    copilot.init();
});

# var V1 = props.globals.initNode("/instrumentation/fmc/vspeeds/V1",140,"DOUBLE");
# var V2 = props.globals.initNode("/instrumentation/fmc/vspeeds/V2",150,"DOUBLE");
# var VR = props.globals.initNode("/instrumentation/fmc/vspeeds/VR",170,"DOUBLE");


# Copilot V-Speed announcements

var copilot = {
	init : func { 
        me.UPDATE_INTERVAL = 0.5; 
        me.loopid = 0; 
		# Initialize state variables.
		me.Eightyannounced = 0;
		me.V1announced = 0;
		me.VRannounced = 0;
		me.V2announced = 0;
		me.PRannounced = 0;
        me.reset(); 
        print("Copilot ready"); 
    }, 
	update : func {
 
	var airspeed = getprop("velocities/airspeed-kt");
	var V1 = getprop("/instrumentation/fmc/vspeeds/V1");
	var VR = getprop("/instrumentation/fmc/vspeeds/VR");
	var V2 = getprop("/instrumentation/fmc/vspeeds/V2");
				
        if ((airspeed > 79) and (me.Eightyannounced == 0)) {
            me.announce("80 Knots");
			me.Eightyannounced = 1;
        } elsif ((airspeed != nil) and (V1 != nil) and (airspeed > V1) and (me.V1announced == 0)) {
            me.announce("V1");
			me.V1announced = 1;
        } elsif ((airspeed != nil) and (VR != nil) and (airspeed > VR) and (me.VRannounced == 0)) {
            me.announce("Rotate");
			me.VRannounced = 1;
        } elsif ((airspeed != nil) and (V2 != nil) and (airspeed > V2) and (me.V2announced == 0)) {
            me.announce("V2");
			me.V2announced = 1;
        } elsif ((me.V2announced == 1) and (me.PRannounced == 0) and (getprop("/position/altitude-agl-ft") > 50) and (getprop("/velocities/vertical-speed-fps") > 5)) 	{
            me.announce("Positive Rate - Gear Up");
			me.PRannounced = 1;
        } elsif ((V1 == nil) or (V2 == nil) or (VR == nil)){
			print ("FMU Toast - Vspeeds not calculated");
		}
		
    },
	announce : func(msg) {
      if (getprop("sim/co-pilot")) {
        setprop("/sim/messages/copilot", msg);
      }
    },
    reset : func {
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }
};
