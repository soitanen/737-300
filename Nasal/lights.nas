# 737-300 Flashing Lights Init
#




strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("sim/model/Boeing-737-300/lighting/strobe", [0.005, 1.4], strobe_switch);
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("sim/model/Boeing-737-300/lighting/beacon", [0.025, 1.5], beacon_switch);
