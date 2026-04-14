// By Scrap Computing

// CPU measurements
//
//  (side view)
//
//  |------ cpu_x ----|
//      ___________     ___
//   __|___________|__   |  cpu_z
//  |_________________| _|_  ___
//     |||||||||||||         _|_ pin_z
//                  <->
//                  pin_border


// Usage:
// $ openscad -P socket3 -p params.json cpu_tray_blaster.scad -o socket3.stl -D grid_x=2 -D grid_y=2

// Socket 3 (486)
cpu_x = 44.5;
cpu_y = 44.5;
cpu_z = 4.0;
pin_z = 4.2;
pin_border = 1.26;
txt = "Socket3";

// This will create a <grid_x> X <grid_y> tray.
grid_x = 2;
grid_y = 2;

// This helps make the tray less flimsy, especially for large grids. If you are OK with a flimsy frame for CPUs with pads then you can set this to 0.
min_pin_z = (grid_x <= 2 && grid_y <= 2) ? 2.2 : 3.2;

// This limit is mainly for LGA CPUS that have pads all the way to the edge. We need a pin border large enough to hold the CPU on the tray.
min_pin_border = 1.2;

// Text.
text_height = 0.5;
text_txt1 = "TRAY";
text_sz = 3.6;
text_txt2 = "BLASTER";
text_version = "v0.3";
text_font = "DejaVu Sans:style=Bold";


// We need a minimum pin height to make sure the base is thick enough.
pin_z_adj = max(pin_z, min_pin_z);
// Otherwise the CPU may fall through the tray.
pin_border_adj = max(pin_border, min_pin_border);

wiggle_room = 0.6; // We set the CPU dimensions this much higher to allow for printing errors
cpu_size_x = cpu_x + wiggle_room;
cpu_size_y = cpu_y + wiggle_room;
cpu_pin_height = pin_z_adj + wiggle_room;
cpu_total_height = pin_z_adj + cpu_z;

// The CPU Lip is the gap that allows you to to remove
// the CPUs from the tray more easily.
// NOTE: These don't need to be changed by the user.
cpu_lip_sz = 24;
cpu_lip_depth = 10;
cpu_lip_thickness = cpu_z + 10;
cpu_lip_upnder_pins_offset = 0.6; // The smaller it is the thicker the grid but harder to remove the CPUs
cpu_lip_z = cpu_pin_height - cpu_lip_upnder_pins_offset;
cpu_distance_from_floor = 1.0;

// The tray
tray_cpu_gap = 3.8; // Gap between the CPUs. The smaller it is the harder it is to place your finger and pick up the CPU.
// The tray's stack lip allows you to stack one tray to the other.
tray_stack_lip_angle = 45;
tray_stack_lip_width = 2.2;
// Helps stacked trays stay in place.
tray_stack_vertical_step = 1.4;
// Reduce the top edge, make it flat.
tray_stack_top_no_edge = 1.6;
tray_stack_lip_top_thickness = 1.8 + tray_stack_vertical_step;
tray_stack_wiggle = 0.6; // We make the top lip larger than the bottom
tray_stack_lip_bot_thickness = tray_stack_lip_top_thickness + 2 * tray_stack_wiggle / tan(tray_stack_lip_angle);
tray_grid_height = cpu_total_height + + cpu_distance_from_floor + tray_stack_lip_top_thickness;

// The gap for the indents that help you pick up the CPU from the tray.
module cpu_lip_impl(cpu_size) {
    translate([-cpu_lip_sz/2, -cpu_size/2 - cpu_lip_depth/2, cpu_lip_z])
        cube([cpu_lip_sz, cpu_lip_depth, cpu_lip_thickness]);
    translate([-cpu_lip_sz/2, +cpu_size/2 - cpu_lip_depth/2, cpu_lip_z])
        cube([cpu_lip_sz, cpu_lip_depth, cpu_lip_thickness]);
}
module cpu_lip() {
    cpu_lip_impl(cpu_size_y);
    rotate([0, 0, 90])cpu_lip_impl(cpu_size_x);   
}

// The CPU with the indent
module cpu() {
        union() {
            xtra_z = cpu_distance_from_floor; // Additional height that makes sure we have a gap under the pins
            translate([-cpu_size_x/2 + pin_border_adj, -cpu_size_y/2 + pin_border_adj, - xtra_z])
                cube([cpu_size_x - 2 * pin_border_adj, cpu_size_y - 2 * pin_border_adj, cpu_pin_height + xtra_z]);
            translate([-cpu_size_x/2, -cpu_size_y/2, cpu_pin_height])
                 cube([cpu_size_x, cpu_size_y, cpu_z]);
            cpu_lip();
        }
}

// The stacking lip at the top of the tray
module tray_stack_cube_top(tray_sz_x, tray_sz_y, height) {
  r = tray_sz_x * cos(45); // cos(45) is because we are using a cylinder to draw a pyramid
  r1 = r;
  r2 = r1 + height * tan(tray_stack_lip_angle);

  // Scale to support non-square cpus
  scale([(tray_sz_x - 2 * tray_stack_lip_width)/tray_sz_x, (tray_sz_y - 2 * tray_stack_lip_width)/tray_sz_x, 1.0])
    rotate([0, 0, 45]) {
      translate([0, 0, tray_stack_vertical_step])cylinder(h = height - tray_stack_vertical_step, r1 = r1, r2 = r2, $fn = 4);
      cylinder(h=tray_stack_vertical_step, r = r1, $fn = 4);
    }
}

// The inverse of the top lip for the bottom of the tray
// that locks with the top lip.
module tray_stack_cube_bot(tray_sz_x, tray_sz_y) {
   difference() {
      cube_height = tray_stack_lip_bot_thickness;
      translate([0, 0, cube_height/2])
         cube([tray_sz_x + 0.1, tray_sz_y + 0.1, cube_height], center = true); // + 0.1 makes the "ghost" vertical planes disappear
         tray_stack_cube_top(tray_sz_x - tray_stack_wiggle, tray_sz_y - tray_stack_wiggle, cube_height);
    }
}

// Draws text at (x,y)
module text_stamp(x, y, txt, rot = 0) {
    z = cpu_lip_z + cpu_distance_from_floor;
    translate([x, y, z])
      rotate([0, 0, rot])
       linear_extrude(text_height)
          text(txt, text_sz, text_font, halign = "center", valign = "baseline");
}

module tray(NX, NY) {
    tray_sz_x = NX * cpu_size_x + (NX + 1) * tray_cpu_gap;
    tray_sz_y = NY * cpu_size_y + (NY + 1) * tray_cpu_gap;

    difference() {
        cube([tray_sz_x, tray_sz_y, tray_grid_height]);

        union() {
            translate([tray_sz_x/2, tray_sz_y/2, 0])
               tray_stack_cube_bot(tray_sz_x, tray_sz_y);
               translate([tray_sz_x/2, tray_sz_y/2, tray_grid_height - tray_stack_lip_top_thickness])
                  union() {
                      // Trim the top to avoid pointy edges
                      translate([0, 0, tray_stack_lip_top_thickness + 0])cube([tray_sz_x + 0.1, tray_sz_y + 0.1, tray_stack_top_no_edge], center = true); // + 0.1 removes "ghost" vertical planes

                      tray_stack_cube_top(tray_sz_x, tray_sz_y, tray_stack_lip_top_thickness);
                  }

               
               for (x = [1:1:NX]) {
                  for (y = [1:1:NY]) {
                     offset_x = cpu_size_x * (x-1)+ tray_cpu_gap * x;
                     offset_y = cpu_size_y * (y-1) + tray_cpu_gap * y;
                     translate([offset_x, offset_y, cpu_distance_from_floor]) 
                      translate([cpu_size_x/2, cpu_size_y/2, 0])cpu();
               }
           }
        }
    }
    
    if (NX >= 2 && NY >= 2) {
      x1 = tray_cpu_gap + cpu_size_x / 2;
      y1 = tray_cpu_gap + cpu_size_y + (tray_cpu_gap - text_sz) / 2;
      text_stamp(x1, y1, text_txt1);

      x2 = tray_cpu_gap + cpu_size_x + tray_cpu_gap + cpu_size_x/2;
      text_stamp(x2 , y1, text_version);
    
      x3 = tray_cpu_gap + cpu_size_x + (tray_cpu_gap - text_sz)/2;
      y3 = tray_cpu_gap + cpu_size_y/2;
      text_stamp(x3, y3, text_txt2, -90); 
      
      y4 = tray_cpu_gap + cpu_size_y + tray_cpu_gap + cpu_size_y/2;
      text_stamp(x3, y4, txt, -90);
    }   
}

tray(grid_x, grid_y);


