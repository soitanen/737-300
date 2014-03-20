##
var vmo = func {
	var a = getprop("/fdm/jsbsim/atmosphere/a-fps");
	var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
	if ( ias == nil ) ias = 0.001;
	if ( ias < 1 ) ias = 100;
	var tas = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
	if ( tas == nil ) tas = 0.001;
	if ( tas == 0 ) tas = 0.001;
	var mmo_kts = a * 0.82 * 0.5913174946 * ias / tas;
	var vmo_kts = 340;
	var time = (mmo_kts - vmo_kts)/2;
	if ( time < 1 or time > 300) time = 1;
	if ( mmo_kts < 340) vmo_kts = mmo_kts;
	setprop("/b733/instrumentation/ASI/vmo-kts", vmo_kts);

	settimer(vmo, time);
}

vmo();
