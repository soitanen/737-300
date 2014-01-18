##

# Adds 2/8 Up/Down control for Vertical Speed Control to existing Altitude Hold Control

# arg[0] is the elevator increment
# arg[1] is the autopilot increment
var incElevator = func {
	
    var auto = props.globals.getNode("/autopilot/locks/altitude", 1);
    var passive = props.globals.getNode("/autopilot/locks/passive-mode", 1);
    if (!auto.getValue() or auto.getValue() == 0  or passive.getValue()) {
        var elevator = props.globals.getNode("/controls/flight/elevator");
        if (elevator.getValue() == nil) {
            elevator.setValue(0.0);
        }
        elevator.setValue(elevator.getValue() + arg[0]);
        if (elevator.getValue() < -1.0) {
            elevator.setValue(-1.0);
        }
        if (elevator.getValue() > 1.0) {
            elevator.setValue(1.0);
        }
    } elsif (auto.getValue() == "altitude-hold") {
        var node = props.globals.getNode("/autopilot/settings/target-altitude-ft", 1);
        if (node.getValue() == nil) {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if (node.getValue() < 0.0) {
            node.setValue(0.0);
        }
    } elsif (auto.getValue() == "vertical-speed-hold") {
        var node = props.globals.getNode("/autopilot/settings/vertical-speed-fpm", 1);
        if (node.getValue() == nil) {
            node.setValue(0.0);
         }
        node.setValue(node.getValue() + arg[1]);
        if (node.getValue() < -3000.0) {
            node.setValue(-3000.0);
        }
				if (node.getValue() > 3000.0) {
            node.setValue(3000.0);
        }
    }
}




# Adds 3/9 PgUp/PgDn control for Mach Hold to existing Throttle Control

##
# arg[0] is the throttle increment
# arg[1] is the auto-throttle target speed increment
var incThrottle = func {
    var auto = props.globals.getNode("/autopilot/locks/speed", 1);
    var passive = props.globals.getNode("/autopilot/locks/passive-mode", 1);
    if (!auto.getValue() or passive.getValue()) {
        foreach(var e; engines) {
            if(e.selected.getValue()) {
                var node = e.controls.getNode("throttle", 1);
                var val = node.getValue() + arg[0];
                node.setValue(val < -1.0 ? -1.0 : val > 1.0 ? 1.0 : val);
            }
        }
    } elsif (auto.getValue() == "speed-with-throttle") {
        var node = props.globals.getNode("/autopilot/settings/target-speed-kt", 1);
        if (node.getValue() == nil) {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if (node.getValue() < 0.0) {
            node.setValue(0.0);
        }
				if (node.getValue() > 350.0) {
            node.setValue(350.0);
        }
    } elsif (auto.getValue() == "mach-with-throttle") {
        var node = props.globals.getNode("/autopilot/settings/target-speed-mach", 1);
        if (node.getValue() == nil) {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[0]);
        if (node.getValue() < 0.0) {
            node.setValue(0.0);
        }
				if (node.getValue() > 0.82) {
            node.setValue(0.82);
        }
    }
}

##
# arg[0] is the aileron increment
# arg[1] is the autopilot target heading increment
var incAileron = func {
    var auto = props.globals.getNode("/autopilot/locks/heading", 1);
    var passive = props.globals.getNode("/autopilot/locks/passive-mode", 1);
    if (!auto.getValue() or passive.getValue()){
        var aileron = props.globals.getNode("/controls/flight/aileron");
        if (aileron.getValue() == nil) {
            aileron.setValue(0.0);
        }
        aileron.setValue(aileron.getValue() + arg[0]);
        if (aileron.getValue() < -1.0) {
            aileron.setValue(-1.0);
        }
        if (aileron.getValue() > 1.0) {
            aileron.setValue(1.0);
        }
    }
    if (auto.getValue() == "dg-heading-hold") {
        var node = props.globals.getNode("/autopilot/settings/heading-bug-deg", 1);
        if (node.getValue() == nil) {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if (node.getValue() < 0.0) {
            node.setValue(node.getValue() + 360.0);
        }
        if (node.getValue() > 360.0) {
            node.setValue(node.getValue() - 360.0);
        }
    }
    if (auto.getValue() == "true-heading-hold") {
        var node = props.globals.getNode("/autopilot/settings/true-heading-deg", 1);
        if (node.getValue() == nil) {
            node.setValue(0.0);
        }
        node.setValue(node.getValue() + arg[1]);
        if (node.getValue() < 0.0) {
            node.setValue(node.getValue() + 360.0);
        }
        if (node.getValue() > 360.0) {
            node.setValue(node.getValue() - 360.0);
        }
    }
}

##
#  Parking brake with optional Announcement
#
var applyParkingBrake = func(v) {
    if (!v) { return; }
    var p = "/controls/gear/brake-parking";
    setprop(p, var i = !getprop(p));

    var pbstatus = "OFF";
    if (getprop("/controls/gear/brake-parking") == 1) { pbstatus = "ON"; }
		if (getprop("sim/co-pilot")) {
		   setprop ("/sim/messages/copilot", "Parking Brake " ~ pbstatus);
    }   


		return i;

}



##
# Initialization.
#
var engines = [];
_setlistener("/sim/signals/fdm-initialized", func {
    var sel = props.globals.getNode("/sim/input/selected", 1);
    var engs = props.globals.getNode("/controls/engines").getChildren("engine");

    foreach(var e; engs) {
        var index = e.getIndex();
        var s = sel.getChild("engine", index, 1);
        if(s.getType() == "NONE") s.setBoolValue(1);
        append(engines, { index: index, controls: e, selected: s });
    }
});

var replaySkip = func(skip_time)
{
    var t = getprop("/sim/replay/time");
    if (t != "")
    {
        t+=skip_time;
        if (t>getprop("/sim/replay/end-time"))
            t = getprop("/sim/replay/end-time");
        if (t<0)
            t=0;
        setprop("/sim/replay/time", t);
    }
}

var speedup = func(speed_up)
{
    var t = getprop("/sim/speed-up");
    if (speed_up < 0)
    {
        t = (t > 1/32) ? t/2 : 1/32;
        if ((t<1)and(0==getprop("/sim/freeze/replay-state")))
            t=1;
    }
    else
    {
        t = (t < 32) ? t*2 : 32;
    }
    setprop("/sim/speed-up", t);
}


#			setprop ("/sim/messages/copilot", "Called");
