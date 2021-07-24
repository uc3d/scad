// This code is protected by the Creative Commons Attribution-ShareAlike 4.0
// International. Refer to https://creativecommons.org/licenses/by-sa/4.0/ to
// understand what you can do with this design.

// Rendering Options
renderToleranceTest = false;       // use this option to print a tolerance test.
renderInternals     = false;       // cut the piece in half and allows you to see its internal.

// Basic Configuration
filamentGuideRadius  = 1.3;    // filament guide radius - 1.75 filament
                               // typically needs a 2mm (1mm) PTFE tube; 2.6mm
                               // provides good tolerances in printed parts.
ptfeTubeOuterRadius  = 2.5;    // outer PTFE tube radius - typically 4mm, but
                               // 5mm provides good tolerances for printed parts.
fittingTapHoleRadius = 5.5/2;  // PC4-M6 screw tap radius - typically M6 tap
                               // diameter is 5 / 2, but 5.5/2 provides good
			       // tolerances for printed parts
adapterOuterRadius   = 4.5;    // adapter outer radius

// Advanced Configuration
imaginaryCircleRadius = 110;                                    // the imaginary circle used to draw the angled parts.
angle                      = acos(1 - 5/imaginaryCircleRadius); // how much of the imaginary circle is kept.


/// --- implementation
_fn = $preview ? 10 : 40;
_straightBottomBodyLength = 10;
_chordLength = 2 * imaginaryCircleRadius * sin(angle/2);

if (renderToleranceTest) {
	intersection() {
		yAdapter();
		bottomCoverBox = _straightBottomBodyLength*1.5;
		rotate([0, 90, 0]) cylinder(r = adapterOuterRadius, h = _straightBottomBodyLength, $fn = _fn*2);
	}
} else {
	yAdapter();
}

module yAdapter() {
	difference() {
		body();
		filamentPath();
		bottomPTFEFitting();
		topLeftPTFEFitting();
		topRightPTFEFitting();
		flattenSurface();
		xRayVision();
	}
}



module body() {
	arcTube(adapterOuterRadius, angle);
	mirror([0,1,0]) arcTube(adapterOuterRadius, angle);
	rotate([0, 90, 0]) cylinder(r = adapterOuterRadius, h = _straightBottomBodyLength, $fn = _fn*2);
}

module filamentPath() {
	// internal filament path
	arcTube(filamentGuideRadius, angle);
	mirror([0,1,0]) arcTube(filamentGuideRadius, angle);
	rotate([0, 90, 0]) translate([0, 0, -1]) cylinder(r = filamentGuideRadius, h = 12, $fn = _fn);
}

module bottomPTFEFitting() {
	translate([10, 0, 0]) rotate([0, -90, 0]) union() {
		translate([0, 0, -1]) cylinder(r = fittingTapHoleRadius, h = 4.5 + 1, $fn = _fn);
		cylinder(r = ptfeTubeOuterRadius, h = 7, $fn = _fn);
	}
}

module topLeftPTFEFitting() {
	translate([0, -imaginaryCircleRadius, 0])
		rotate([0, 0, angle - 3.5])
		translate([-7, imaginaryCircleRadius, 0])
		rotate([0, 90, 0])
	union() {
		cylinder(r = fittingTapHoleRadius, h = 4.5, $fn = _fn);
		translate([0, 0, 4.5]) cylinder(r1 = fittingTapHoleRadius, r2 = filamentGuideRadius-0.4, h = 7-4.5 + 2, $fn = _fn);
	}
}

module topRightPTFEFitting() {
	mirror([0, 1, 0]) topLeftPTFEFitting();
}

module flattenSurface() {
	translate([0,0,-3*adapterOuterRadius+0.6]) plank(adapterOuterRadius);
}

module xRayVision() {
	if (renderInternals) {
		translate([0,0,-adapterOuterRadius]) plank(adapterOuterRadius);
	}
}

// helpers
module arcTube(radius, angle) {
	translate([0, -imaginaryCircleRadius, 0]) rotate([0,0,90]) rotate_extrude(angle = angle, $fn = _fn*6, convexity = 10) {
		translate([imaginaryCircleRadius, 0, 0]) circle(r = radius, $fn = _fn*2);
	}
}

module plank(height) {
	translate([0, -adapterOuterRadius, height]) cube([ _straightBottomBodyLength, adapterOuterRadius*2, height]);
	// account that the tube makes a curve and needs some extra fudge to cover it all.
	cl = _chordLength + 2;
	translate([-cl, cl/-2, height]) cube([cl, cl, height]);
}