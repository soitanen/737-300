# Doors system


var DoorP1 = props.globals.initNode("/controls/switches/passengerdoor1",0,"DOUBLE");
var DoorP2 = props.globals.initNode("/controls/switches/passengerdoor2",0,"DOUBLE");
var DoorP3 = props.globals.initNode("/controls/switches/passengerdoor3",0,"DOUBLE");
var DoorP4 = props.globals.initNode("/controls/switches/passengerdoor4",0,"DOUBLE");
var CPDoor = props.globals.initNode("/controls/switches/cockpitdoor",1,"DOUBLE");

var openclosedoor = func (indevice) {
				var wdevice = props.globals.getNode(indevice) ;
				var devicevalue = wdevice.getValue();
				if ( devicevalue < 0.01 ) {
					interpolate(wdevice.getPath(), 1, 5);
				} else {
					interpolate(wdevice.getPath(), 0, 5);
				}				

}
