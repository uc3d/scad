// This code is protected by the Creative Commons Attribution-ShareAlike 4.0
// International. Refer to https://creativecommons.org/licenses/by-sa/4.0/ to
// understand what you can do with this design.

// This code depends on NopSCADLib. Refer to
// https://github.com/nophead/NopSCADlib for more information.
// NopSCADLib uses GNU GPLv3 - beware of copyrights limitations.
include <NopSCADlib/lib.scad>;


fullAssembly();
// testTolerances();
// caseBoxAssembly();
// caseCoverAssembly();
// wireLoomConduitClamp();

// Advanced Configurations
boxWallThickness                  = 3;
boxHeight                         = 40;
squareNutHolderPos                = [ [12,2,34], [104,2,34], [12,112,34], [104,112,34] ];
squareNutHolderMirror             = [ [ 0,0,0 ],  [ 0,0,0 ],   [ 0,1,0 ],    [ 0,1,0 ] ];
wiringLoomHoleInternalDiameter    = 12;
wiringLoomHoleTopOuterDiameter    = 15;
wiringLoomHoleBottomOuterDiameter = 18;
wireLoomHeight                    = 15;
hotendWireLoomPos                 = [   0,25,32];
xCarriageWireLoomPos              = [   0,90,32];
bedWireLoomPos                    = [97.5, 0,32];
bottomExtrusionFitHelperPos       = [ [163, 40,28.75], [163, 40,8.75] ];
backExtrusionFitHelperPos         = [ [ 45,114,28.75], [ 45,114,8.75],
                                      [100,114,28.75], [100,114,8.75] ];
backExtrusionFitHelperMirror      = [ [ 0,0,0 ], [ 0,0,0 ],
                                      [ 0,1,0 ], [ 0,1,0 ] ];
mainboardScrewsPos                = [ [ 30,9,3],  [ 30,85,3],
                                      [132,9,3],  [132,85,3] ];
trapezoidExitHolePos              = [146.5,34,0];
mainboardUSBHole                  = [49.5,0,9.5];
mainboardSDHole                   = [68.0,0,6.0];
internalWireGuidesPos             = [ [50,91,0], [80,91,0] ];
coverHeight                       = 3;
coverFanHolesPos                  = [71,78,0];

module caseBoxAssembly() {
	difference() {
		// Box and obtrusions
		union() {
			box();

			// square nut holders
			for (i = [0:len(squareNutHolderPos)-1]) {
				translate(squareNutHolderPos[i]) mirror(squareNutHolderMirror[i]) squareNutHolderObtrusion();
			}

			// wire looms
			translate(hotendWireLoomPos)    rotate([0, -90,0]) wireLoomConduitObtrusionBody();
			translate(xCarriageWireLoomPos) rotate([0, -90,0]) wireLoomConduitObtrusionBody();
			translate(bedWireLoomPos)       rotate([90,-90,0]) wireLoomConduitObtrusionBody();

			// bottom 2040 extrusion fit helpers
			for (i = [0:len(bottomExtrusionFitHelperPos)-1]) {
				translate(bottomExtrusionFitHelperPos[i]) extrusionObtrusionFit();
			}

			// back 2040 extrusion fit helpers
			for (i = [0:len(backExtrusionFitHelperPos)-1]) {
				translate(backExtrusionFitHelperPos[i]) rotate([0,0,90]) extrusionObtrusionFit();
			}

			// mainboard screws
			for (i = [0:len(mainboardScrewsPos)-1]) {
				translate(mainboardScrewsPos[i]) mainboardScrewObtrusion();
			}

			// internal wire guides
			for (i = [0:len(internalWireGuidesPos)-1]) {
				translate(internalWireGuidesPos[i]) cube([3,20,35]);
			}
		}
		// Holes
		union() {
			// square nut holders
			for (i = [0:len(squareNutHolderPos)-1]) {
				translate(squareNutHolderPos[i]) mirror(squareNutHolderMirror[i]) squareNutHolderHoles();
			}

			// wire looms
			translate(hotendWireLoomPos)    rotate([ 0,-90,0]) wireLoomConduitObtrusionHoles();
			translate(xCarriageWireLoomPos) rotate([ 0,-90,0]) wireLoomConduitObtrusionHoles();
			translate(bedWireLoomPos)       rotate([90,-90,0]) wireLoomConduitObtrusionHoles();

			// bottom 2040 extrusion fit helpers
			for (i = [0:len(bottomExtrusionFitHelperPos)-1]) {
				translate(bottomExtrusionFitHelperPos[i]) extrusionFitHelperHoles();
			}

			// back 2040 extrusion fit helpers
			for (i = [0:len(backExtrusionFitHelperPos)-1]) {
				translate(backExtrusionFitHelperPos[i]) rotate([0,0,90]) extrusionFitHelperHoles();
			}

			// mainboard screws
			for (i = [0:len(mainboardScrewsPos)-1]) {
				translate(mainboardScrewsPos[i]) mainboardScrewHoleAndNutTrap();
			}

			// trapezoid exit hole
			translate(trapezoidExitHolePos) minkowski() { cube([20,32,4]); sphere(r=2); }

			//translate([0,+324+114,43]) rotate([0,180,180]) import("skr-bear-cover-no-fan.fixed.stl");

			// mainboard USB and SD card holes
			translate(mainboardUSBHole) cube([13,3,11]);
			translate(mainboardSDHole)  cube([16,3,7]);

			// internal wire guides
			for (i = [0:len(internalWireGuidesPos)-1]) {
				translate(internalWireGuidesPos[i]) translate([0,boxWallThickness,boxWallThickness]) cube([3,20-boxWallThickness,35-boxWallThickness*2]);
			}
		}
	}
}

module box() {
	difference() {
		linear_extrude(height=boxHeight) backBody();
		translate([0,0,boxWallThickness]) linear_extrude(height=boxHeight-boxWallThickness+1) offset(delta=-boxWallThickness) backBody();
		// grill holes
		linear_extrude(height=boxHeight) for (i = [10:8:8*17]) {
			hull() {
				translate([i,20,0]) circle(r=2);
				translate([i,75,0]) circle(r=2);
			}
		}
	}
}

module squareNutHolderObtrusion() {
	hull() {
		translate([0,0,0]) cube([9,9,6]);
		translate([0,0,-7]) cube([9,1,7]);
	}
}

module wireLoomConduitObtrusionBody() {
	difference() {
		wireLoomConduitObtrusionPlatonic();
		translate([0,wiringLoomHoleBottomOuterDiameter*2/-2,0]) cube([wiringLoomHoleBottomOuterDiameter,wiringLoomHoleBottomOuterDiameter*2,wireLoomHeight]);
	}
}

module wireLoomConduitObtrusionPlatonic() {
	difference() {
		union() {
			cylinder(d2=wiringLoomHoleTopOuterDiameter, d1=wiringLoomHoleBottomOuterDiameter, h=wireLoomHeight);
			scale([1,1.7,1]) cylinder(d2=wiringLoomHoleTopOuterDiameter, d1=wiringLoomHoleBottomOuterDiameter, h=wireLoomHeight*2/3);
			// TODO: parameterize this hull
			hull() {
				translate([-7.5,-2.5,wireLoomHeight/3]) cube([1,5,10.0]);
				translate([-16,-2.5,-1]) cube([9,5,1]);
			}
		}

		screwHolesZPos = wireLoomHeight/2-4;
		translate([+7.5,+1*(wiringLoomHoleInternalDiameter-2),screwHolesZPos]) rotate([0,-90,0]) cylinder(r=screw_head_radius(M3_cap_screw), h=screw_head_height(M3_cap_screw)+2);
		translate([+7.5,-1*(wiringLoomHoleInternalDiameter-2),screwHolesZPos]) rotate([0,-90,0]) cylinder(r=screw_head_radius(M3_cap_screw), h=screw_head_height(M3_cap_screw)+2);

		translate([wiringLoomHoleBottomOuterDiameter/2,+1*(wiringLoomHoleInternalDiameter-2),screwHolesZPos]) rotate([0,-90,0]) cylinder(r=screw_clearance_radius(M3_cap_screw), h=wireLoomHeight+6);
		translate([wiringLoomHoleBottomOuterDiameter/2,-1*(wiringLoomHoleInternalDiameter-2),screwHolesZPos]) rotate([0,-90,0]) cylinder(r=screw_clearance_radius(M3_cap_screw), h=wireLoomHeight+6);

		translate([-5,+1*(wiringLoomHoleInternalDiameter-2),screwHolesZPos]) rotate([0,-90,0]) nut_trap(screw = M3_cap_screw, nut = M3_nut, h=3);
		translate([-5,-1*(wiringLoomHoleInternalDiameter-2),screwHolesZPos]) rotate([0,-90,0]) nut_trap(screw = M3_cap_screw, nut = M3_nut, h=3);
	}
}

module extrusionObtrusionFit() {
	hull() {
		translate([0,0,0]) cube([1,20,8.75]);
		translate([1.2,0,1]) cube([1,20,6.5]);
	}
}

module mainboardScrewObtrusion() {
	hull() {
		cylinder(d=9, h=1);
		cylinder(d=7, h=4);
	}
}

module squareNutHolderHoles() {
	union() {
		translate([4.5,5,0]) cylinder(r=screw_clearance_radius(M3_cap_screw), h=8);
		translate([0,2,2]) scale([1.3,1.2,1.2]) cube([nut_square_width(M3nS_thin_nut),nut_square_width(M3nS_thin_nut),nut_square_thickness(M3nS_thin_nut)]);
	}
}

module wireLoomConduitObtrusionHoles() {
	difference() {
		hull() {
			translate([0,0,-6])                                     cylinder(d=wiringLoomHoleInternalDiameter, h=wireLoomHeight+6);
			translate([10,0,-6]) cylinder(d=wiringLoomHoleInternalDiameter, h=wireLoomHeight+6);
		}
		translate([-wiringLoomHoleInternalDiameter/2+1.0,0,-6]) cylinder(d=4.1, h=wireLoomHeight);
	}
	translate([-wiringLoomHoleInternalDiameter/2+1.0,0,-6]) cylinder(d=3.1, h=wireLoomHeight+6);
}

module extrusionFitHelperHoles() {
	translate([-boxWallThickness,10.2,4]) rotate([0,90,0]) cylinder(r=screw_clearance_radius(M5_cap_screw), h=boxWallThickness+10);
}

module mainboardScrewHoleAndNutTrap() {
	translate([0,0,-3]) cylinder(r=screw_clearance_radius(M3_cap_screw), h=boxWallThickness+10);
	translate([0,0,-1.75]) nut_trap(screw=M3_cap_screw,nut=M3_nut, horizontal=true, supported=true, h = 1, depth=2.5/2);
}

module backBody() {
	union() {
		polygon([
			[   0,   0],
			[   0, 114],
			[ 123, 114],
			[ 143,  94],
			[ 143,   0],
		]);
		polygon([
			[ 143,  6.5],
			[ 143, 94.0],
			[ 164, 73.0],
			[ 164, 27.5],
		]);
	}
}

module caseCoverAssembly() {
	difference() {
		linear_extrude(height=coverHeight) backBody();
		linear_extrude(height=coverHeight) difference() {
			for (i = [10:8:8*17]) {
				hull() {
					translate([i,20,0]) circle(r=2);
					translate([i,75,0]) circle(r=2);
				}
			}
			fanHolesBaseWidth = fan_width(fan40x11)+10;
			translate(coverFanHolesPos)
				translate([-fanHolesBaseWidth/2,-fanHolesBaseWidth/2,0])
				square(fanHolesBaseWidth);
		}

		for (i = [0:len(squareNutHolderPos)-1]) {
			translate([
				squareNutHolderPos[i][0],
				squareNutHolderPos[i][1],
				0,
			]) mirror(squareNutHolderMirror[i]) translate([4.5,5,0]) cylinder(r=screw_clearance_radius(M3_cap_screw)*1.2, h=8);
		}

		translate(coverFanHolesPos) fan_holes(fan40x11, poly = false, screws = true, h = 100);
	}
}

module wireLoomConduitClamp() {
	difference() {
		wireLoomConduitObtrusionPlatonic();
		translate([-wiringLoomHoleBottomOuterDiameter,wiringLoomHoleBottomOuterDiameter*2/-2,-2]) cube([wiringLoomHoleBottomOuterDiameter,wiringLoomHoleBottomOuterDiameter*2,wireLoomHeight+2]);
		translate([0,0,-6]) cylinder(d=wiringLoomHoleInternalDiameter, h=wireLoomHeight+6);
	}
}

module testTolerances() {
	translate([0,+15,0]) testSquareNutTolerance();
	translate([0,-15,0]) testWireLoomClampTolerante();
}

module testSquareNutTolerance() {
	rotate([90,0,0]) difference() {
		squareNutHolderObtrusion();
		squareNutHolderHoles();
	}
}

module testWireLoomClampTolerante() {
	difference() {
		wireLoomConduitObtrusionBody();
		wireLoomConduitObtrusionHoles();
		translate([-10,0,-3/2]) cube([20,20,3], center=true);
	}
	translate([10,0,0]) wireLoomConduitClamp();
}

module fullAssembly() {
	$fn = $preview ? 15 : 100;
	caseBoxAssembly();
	# translate([0,0,43]) caseCoverAssembly();
	# translate([0,0,3]) translate(hotendWireLoomPos)    rotate([0, -90,0]) wireLoomConduitClamp();
	# translate([0,0,3]) translate(xCarriageWireLoomPos) rotate([0, -90,0]) wireLoomConduitClamp();
	# translate([0,0,3]) translate(bedWireLoomPos)       rotate([90,-90,0]) wireLoomConduitClamp();
}
