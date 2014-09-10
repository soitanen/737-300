##
var Point = {
	new: func(x, y) {
		var m = { parents: [Point] };
		m._x = x;
		m._y = y;
		return m;
	},
	x: func { return me._x },
	y: func { return me._y },
	xy: func { return [me._x, me._y] },
};

var Polygon = {
	new: func() {
		var m = { parents: [Polygon] };
		m._points = [];
		return m; # return the temporary object
	},
	add_point: func(p) {
		append(me._points, p);
	},
	get_point: func(point_index) {
		return me._points[point_index];
	},
};

var p1_a = Point.new(0, 0);
var p2_a = Point.new(1, 1);
var p3_a = Point.new(5, 0);

var pol_a = Polygon.new();

pol_a.add_point(p1_a);
pol_a.add_point(p2_a);
pol_a.add_point(p3_a);

print("X ", pol_a.get_point(0).x," Y ", pol_a.get_point(0).y);

