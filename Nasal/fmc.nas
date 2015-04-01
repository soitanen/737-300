##
var Point = {
	new: func(x, y) {
		var m = { parents: [Point] };
		m._x = x;
		m._y = y;
		return m;
	},
	x: func { return me._x; },
	y: func { return me._y; },
	xy: func { return [me._x, me._y]; },
	set_x: func(x) { me._x = x; },
	set_y: func(y) { me._y = y; },
};

var Polygon = {
	new: func() {
		var m = { parents: [Polygon] };
		m._points = [];
		m._size = 0;
		return m; # return the temporary object
	},
	add_point: func(p) {
		append(me._points, p);
		me._size += 1;
	},
	get_point: func(point_index) {
		return me._points[point_index];
	},
	get_size: func() {
		return me._size;
	},
};

var Zone = {
	new: func() {
		var m = { parents: [Zone] };
		m._polygons = [];
		m._size = 0;
		return m; # return the temporary object
	},
	add_polygon: func(p) {
		append(me._polygons, p);
		me._size += 1;
	},
	get_polygon: func(point_index) {
		return me._polygons[point_index];
	},
	get_size: func() {
		return me._size;
	},
};

var p1_a = Point.new(3, -1);
var p2_a = Point.new(3, 4580);
var p3_a = Point.new(23, 4290);
var p4_a = Point.new(40, -1);

var p1_b = Point.new(3, 4580);
var p2_b = Point.new(3, 9001);
var p3_b = Point.new(12, 8600);
var p4_b = Point.new(26, 6340);
var p5_b = Point.new(56, -1);
var p6_b = Point.new(40, -1);
var p7_b = Point.new(23, 4290);

var p1_c = Point.new(3, 9001);
var p2_c = Point.new(29, 9001);
var p3_c = Point.new(50, 4600);
var p4_c = Point.new(65, -1);
var p5_c = Point.new(56, -1);
var p6_c = Point.new(26, 6340);
var p7_c = Point.new(12, 8600);

var p1_d = Point.new(29, 9001);
var p2_d = Point.new(55, 9001);
var p3_d = Point.new(72, 670);
var p4_d = Point.new(72, -1);
var p5_d = Point.new(65, -1);
var p6_d = Point.new(50, 4600);

var p1_a_20k = Point.new(3, -1);
var p2_a_20k = Point.new(3, 6220);
var p3_a_20k = Point.new(27, 6000);
var p4_a_20k = Point.new(36, 4020);
var p5_a_20k = Point.new(36, 2030);
var p6_a_20k = Point.new(44, -1);

var p1_b_20k = Point.new(3, 6220);
var p2_b_20k = Point.new(3, 9000);
var p3_b_20k = Point.new(19, 9000);
var p4_b_20k = Point.new(40, 6050);
var p5_b_20k = Point.new(50, 3000);
var p6_b_20k = Point.new(50, 1950);
var p7_b_20k = Point.new(56, -1);
var p8_b_20k = Point.new(44, -1);
var p9_b_20k = Point.new(36, 2030);
var p10_b_20k = Point.new(36, 4020);
var p11_b_20k = Point.new(27, 6000);

var p1_c_20k = Point.new(19, 9000);
var p2_c_20k = Point.new(35, 9000);
var p3_c_20k = Point.new(44, 7550);
var p4_c_20k = Point.new(55, 4770);
var p5_c_20k = Point.new(65, -1);
var p6_c_20k = Point.new(56, -1);
var p7_c_20k = Point.new(50, 1950);
var p8_c_20k = Point.new(50, 3000);
var p9_c_20k = Point.new(40, 6050);

var p1_d_20k = Point.new(35, 9000);
var p2_d_20k = Point.new(56, 9000);
var p3_d_20k = Point.new(72, 1080);
var p4_d_20k = Point.new(72, -1);
var p5_d_20k = Point.new(65, -1);
var p6_d_20k = Point.new(55, 4770);
var p7_d_20k = Point.new(44, 7550);


var pol_a = Polygon.new();
var pol_b = Polygon.new();
var pol_c = Polygon.new();
var pol_d = Polygon.new();

var pol_a_20k = Polygon.new();
var pol_b_20k = Polygon.new();
var pol_c_20k = Polygon.new();
var pol_d_20k = Polygon.new();

var zone_22k = Zone.new();
var zone_20k = Zone.new();

zone_22k.add_polygon(pol_a);
zone_22k.add_polygon(pol_b);
zone_22k.add_polygon(pol_c);
zone_22k.add_polygon(pol_d);

zone_20k.add_polygon(pol_a_20k);
zone_20k.add_polygon(pol_b_20k);
zone_20k.add_polygon(pol_c_20k);
zone_20k.add_polygon(pol_d_20k);

pol_a.add_point(p1_a);
pol_a.add_point(p2_a);
pol_a.add_point(p3_a);
pol_a.add_point(p4_a);

pol_b.add_point(p1_b);
pol_b.add_point(p2_b);
pol_b.add_point(p3_b);
pol_b.add_point(p4_b);
pol_b.add_point(p5_b);
pol_b.add_point(p6_b);
pol_b.add_point(p7_b);

pol_c.add_point(p1_c);
pol_c.add_point(p2_c);
pol_c.add_point(p3_c);
pol_c.add_point(p4_c);
pol_c.add_point(p5_c);
pol_c.add_point(p6_c);
pol_c.add_point(p7_c);

pol_d.add_point(p1_d);
pol_d.add_point(p2_d);
pol_d.add_point(p3_d);
pol_d.add_point(p4_d);
pol_d.add_point(p5_d);
pol_d.add_point(p6_d);

pol_a_20k.add_point(p1_a_20k);
pol_a_20k.add_point(p2_a_20k);
pol_a_20k.add_point(p3_a_20k);
pol_a_20k.add_point(p4_a_20k);
pol_a_20k.add_point(p5_a_20k);
pol_a_20k.add_point(p6_a_20k);

pol_b_20k.add_point(p1_b_20k);
pol_b_20k.add_point(p2_b_20k);
pol_b_20k.add_point(p3_b_20k);
pol_b_20k.add_point(p4_b_20k);
pol_b_20k.add_point(p5_b_20k);
pol_b_20k.add_point(p6_b_20k);
pol_b_20k.add_point(p7_b_20k);
pol_b_20k.add_point(p8_b_20k);
pol_b_20k.add_point(p9_b_20k);
pol_b_20k.add_point(p10_b_20k);
pol_b_20k.add_point(p11_b_20k);

pol_c_20k.add_point(p1_c_20k);
pol_c_20k.add_point(p2_c_20k);
pol_c_20k.add_point(p3_c_20k);
pol_c_20k.add_point(p4_c_20k);
pol_c_20k.add_point(p5_c_20k);
pol_c_20k.add_point(p6_c_20k);
pol_c_20k.add_point(p7_c_20k);
pol_c_20k.add_point(p8_c_20k);
pol_c_20k.add_point(p9_c_20k);

pol_d_20k.add_point(p1_d_20k);
pol_d_20k.add_point(p2_d_20k);
pol_d_20k.add_point(p3_d_20k);
pol_d_20k.add_point(p4_d_20k);
pol_d_20k.add_point(p5_d_20k);
pol_d_20k.add_point(p6_d_20k);
pol_d_20k.add_point(p7_d_20k);

var isClockWise = func (pA, pB, pC) {
	if ( (pB.x()-pA.x())*(pC.y()-pA.y()) - (pC.x() - pA.x())*(pB.y() - pA.y()) < 0) { return 1; }
	else { return 0;}
}

var isRay_x_Line = func (pA, pB, pD) { # pA - Ray start point, B and D - two other points
	if (pA.x() == pB.x()) { pB.set_x(pB.x() + 0.001); }
	if (pA.x() == pD.x()) { pD.set_x(pD.x() + 0.001); }
	if (pA.y() == pB.y()) { pB.set_y(pB.y() + 0.001); }
	if (pA.y() == pD.y()) { pD.set_y(pD.y() + 0.001); }
	var pC = Point.new(100, pA.y());
	if ( isClockWise (pA, pB, pC) ) {
		return (isClockWise (pB, pC, pD) and isClockWise (pC, pD, pA) and isClockWise (pD, pA, pB));		
	} elsif ( !isClockWise (pA, pB, pC) )  {
		return (!isClockWise (pB, pC, pD) and !isClockWise (pC, pD, pA) and !isClockWise (pD, pA, pB));
	} else {
		return 0;
	}
}

var isPointInPolygon = func (pA, pol) {
	var parity = 0;
	var pol_size = pol.get_size();

	for ( var i = -1; i < pol_size - 1; i += 1 ) {
		if ( isRay_x_Line(pA, pol.get_point(i), pol.get_point(i+1)) ) {  parity = 1 - parity;}
	}
	return parity;
}

var whichZone = func (pA, zon) {
	var zone_size = zon.get_size();
	var result = 0;

	for ( var i = 0; i < zone_size; i += 1) {
		if (isPointInPolygon(pA, zon.get_polygon(i))) {return i+1;}
	}
}

var recalcConditions = func {
	var elevation = getprop("/position/ground-elev-ft"); #FIXME need to get takeoff runway elevation, not current
	var oat = getprop("/environment/temperature-degc");
	var derate_20k = getprop("/instrumentation/fmc/derated-to/method-derate-20k");
	var assumed = getprop("/instrumentation/fmc/derated-to/method-assumed");

	if (assumed) {
		var temperature = getprop("/instrumentation/fmc/derated-to/assumed-temp-degc");
	} else {
		var temperature = oat;
	}
	if (temperature < 4) {temperature = 4;}
	if (temperature > 71.9) {temperature = 71.9;}
	if (elevation < 0) {elevation = 0;}
	if (derate_20k) {
		var searchZone = zone_20k;
	} else {
		var searchZone = zone_22k;
	}

	var calcPoint = Point.new(temperature, elevation);
	var zone_number = whichZone(calcPoint, searchZone);
	setprop("/instrumentation/fmc/derated-to/zone", zone_number);
}

setlistener("/instrumentation/fmc/derated-to/assumed-temp-degc", recalcConditions, 0, 0 );
setlistener("/instrumentation/fmc/derated-to/method-derate-20k", recalcConditions, 0, 0 );
setlistener("/instrumentation/fmc/derated-to/method-assumed", recalcConditions, 0, 0 );
setlistener("/sim/signals/fdm-initialized", recalcConditions, 0, 0 );
