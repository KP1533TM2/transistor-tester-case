$fn=64;

/*pcb_width = 73.7;
pcb_length = 83.4;*/    // actual board measurements that I took with caliper
pcb_width = 74.5;
pcb_length = 84;
pcb_thickness = 1.5;
pcb_round_radius = 2;
pcb_shelf_width = 2;
bottom_part_height = 10;
higher_part_height = 20;
wall_thickness = 1.5;
inner_chamfer_r = 1;

t = wall_thickness;

/* case dimensions */
dx = pcb_width+wall_thickness*2;
dy = pcb_length+wall_thickness*2;

union() {
make_base();
make_extension();
/* put some nice artwork into the bottom of the case :)
   (I'm planning to print the case with translucent PLA plastic)
*/
translate([dx/2+30, dy/2-30, wall_thickness]) mirror([1,0,0]) linear_extrude(height = wall_thickness, center = false, convexity = 10)
   import (file = "artwork.dxf", layer = "0");
}

/*-----------------------------------------------------------------------------*/
module make_extension() {
    extension_length = 30;
    extension_height = 20;
    extension_cutoff_angle = 65;
    cylinder_z = bottom_part_height + extension_height/2 + 5;
    sphere_penetration = 0.75;
    sphere_radius = 2.5;
    outer_round = pcb_round_radius + wall_thickness;
    difference() {
        translate([0,dy-extension_length-outer_round,bottom_part_height]) rounded_verticals_cube(dx,extension_length+outer_round,extension_height,outer_round);
        translate([wall_thickness,dy-extension_length-outer_round+wall_thickness,bottom_part_height]) rounded_verticals_cube(pcb_width,extension_length+outer_round-wall_thickness*2,extension_height,pcb_round_radius);
        translate([0,dy-extension_length-outer_round,bottom_part_height]) cube([dx,outer_round,extension_height]);
        translate([0,dy-extension_length,bottom_part_height]) rotate([extension_cutoff_angle,0,0]) cube([dx,dy,extension_height]);
        translate([0,dy-10,cylinder_z]) rotate([0,90,0]) cylinder(h = dx, r = 2.5);
        
        //translate([sphere_penetration-sphere_radius,dy-17.5,cylinder_z]) sphere(sphere_radius);
        //translate([dx-sphere_penetration+sphere_radius,dy-17.5,cylinder_z]) sphere(sphere_radius);
    }
    
}

//projection(cut=true) translate([0,0,-9]) make_base();
//projection(cut=true) translate([0,0,-8]) make_base();

module make_base() {
    difference() {
        union() {
            difference() {
                // make base
                cube([dx,dy,bottom_part_height]);
                // make a small shelf to rest our pcb on
                translate([wall_thickness,wall_thickness,bottom_part_height-pcb_thickness]) rounded_verticals_cube(pcb_width,pcb_length,pcb_thickness+1, pcb_round_radius);
                // carve the rest of the box
                translate([pcb_shelf_width+wall_thickness,pcb_shelf_width+wall_thickness,wall_thickness]) rounded_bottom_cube(pcb_width-pcb_shelf_width*2, pcb_length-pcb_shelf_width*2,bottom_part_height,2);
            }
            // make screw corners
            make_rounded_corners(dx,dy,wall_thickness+11,wall_thickness+11,8.5,2);
        }
        // subtract corners
        make_rounded_corners(dx,dy,wall_thickness+8,wall_thickness+8,5,2);
        // make screw holes
        hole_offset = 4;
        hole_radius = 2;
        translate([wall_thickness+hole_offset,wall_thickness+hole_offset,0]) cylinder (h = bottom_part_height, r = hole_radius);
        translate([dx-wall_thickness-hole_offset,wall_thickness+hole_offset,0]) cylinder (h = bottom_part_height, r = hole_radius);
        translate([wall_thickness+hole_offset,dy-wall_thickness-hole_offset,0]) cylinder (h = bottom_part_height, r = hole_radius);
        translate([dx-wall_thickness-hole_offset,dy-wall_thickness-hole_offset,0]) cylinder (h = bottom_part_height, r = hole_radius);
        //rounded_bottom_cube(dx, dy, bottom_part_height, 3);        
        // round the bottom and corners
        make_rounded_bottom();
        
        // cut hole for usb connector
        translate([0,40+wall_thickness,bottom_part_height-pcb_thickness+1]) cube([5,9,5]);
        
        // make small notches for cover to latch on
        notches_z = (bottom_part_height-(pcb_round_radius+wall_thickness))/2+(pcb_round_radius+wall_thickness);
        notches_y_offset = wall_thickness+15;
        notches_radius = 0.7;
        translate([0,notches_y_offset,notches_z]) rotate([-90,0,0]) cylinder(r = notches_radius, h = 10);
        translate([dx,notches_y_offset,notches_z]) rotate([-90,0,0]) cylinder(r = notches_radius, h = 10);
        
        
    }
    
}

module make_rounded_bottom() {
    difference() {
        translate([-5, -5, -5]) cube([dx+10, dy+10, bottom_part_height+5]);
        rounded_bottom_cube(dx, dy, bottom_part_height, pcb_round_radius+wall_thickness);
    }
}

module make_rounded_corners(xspacing, yspacing, xdim, ydim, zdim, radius) {
        translate([0,0,0]) mirror([0,0,0]) rounded_corner_cube(xdim,ydim,zdim, radius);
        translate([xspacing,0,0]) mirror([1,0,0]) rounded_corner_cube(xdim,ydim,zdim, radius);
        translate([0,yspacing,0]) mirror([0,1,0]) rounded_corner_cube(xdim,ydim,zdim, radius);
        translate([xspacing,yspacing,0]) mirror([1,1,0]) rounded_corner_cube(ydim,xdim,zdim, radius);
}

module rounded_bottom_cube(xdim, ydim, zdim, rdim) {
    r = rdim/2;
    hull()
    {
        translate([rdim,rdim,rdim]) sphere(r = rdim);
        translate([xdim-rdim,rdim,rdim]) sphere(r = rdim);
        translate([rdim,ydim-rdim,rdim]) sphere(r = rdim);
        translate([xdim-rdim,ydim-rdim,rdim]) sphere(r = rdim);
        translate([rdim,rdim,rdim]) cylinder(r=rdim, h=zdim-r);
        translate([xdim-rdim,rdim,rdim]) cylinder(r=rdim, h=zdim-r);
        translate([rdim,ydim-rdim,rdim]) cylinder(r=rdim, h=zdim-r);
        translate([xdim-rdim,ydim-rdim,rdim]) cylinder(r=rdim, h=zdim-r);
    }
}

module rounded_verticals_cube(xdim, ydim, zdim, radius) {
    hull() {
        translate([radius,radius,0]) cylinder(h = zdim, r = radius);
        translate([xdim-radius,radius,0]) cylinder(h = zdim, r = radius);
        translate([radius,ydim-radius,0]) cylinder(h = zdim, r = radius);
        translate([xdim-radius,ydim-radius,0]) cylinder(h = zdim, r = radius);
    }
}

module rounded_corner_cube(xdim, ydim, zdim, rdim, rotation) {
    r = rdim/2;
    union(){
        translate([xdim-rdim,ydim-rdim,0]) cylinder(r=rdim, h=zdim);
        translate([0,0,0]) cube([xdim-rdim, ydim, zdim]);
        translate([xdim-rdim,0,0]) cube([rdim, ydim-rdim, zdim]);
        }
}