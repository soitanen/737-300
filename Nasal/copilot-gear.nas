##

var gearpos = func {

if (getprop("sim/co-pilot")) {

# Check for gear retraction and confirm gear up

  if (getprop("/gear/gear/position-norm") == 0) {
     setprop("/sim/messages/copilot", "Confirmed - Gear Up");
  }

# Check for gear extension and confirm - then advise landing speed
	
	if (getprop("/gear/gear/position-norm") == 1) {
     setprop("/sim/messages/copilot", "Gear Down - three green");

# Calculate Recommended Landing Speeds		 

  var grossweight = getprop("fdm/jsbsim/inertia/weight-lbs") or 0.00;
   grossweight_kg = math.round(grossweight * 0.4536, 100);
   grossweight = math.round(grossweight, 100);

   vref15 = math.round(getprop("/instrumentation/fmc/v-ref-15"), 1);
   vref30 = math.round(getprop("/instrumentation/fmc/v-ref-30"), 1);
   vref40 = math.round(getprop("/instrumentation/fmc/v-ref-40"), 1);

	if (grossweight > 114000) {
		setprop("/sim/messages/copilot", "Gross Weight "~grossweight~" lb, "~grossweight_kg~" kg. EXCEED MAXIMUM LANDING WEIGHT!!!");
	} else {
	setprop("/sim/messages/copilot", "Gross Weight "~grossweight~" lb, "~grossweight_kg~" kg. Vref15 "~vref15~"; Vref30 "~vref30~"; Vref40 "~vref40~" kts");
	}
  }

}
}


setlistener("/gear/gear/position-norm", gearpos, 0, 0);

