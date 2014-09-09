
call_speedbrakevalve = func {
   WOW = getprop("/gear/gear[1]/wow");
   
	
 if (WOW == 0) { setprop("/controls/flight/speedbrake", 0.0);}
 
 settimer(call_speedbrakevalve, 0.0);   
}
 
init = func {
   settimer(call_speedbrakevalve, 0.0);
}

init();