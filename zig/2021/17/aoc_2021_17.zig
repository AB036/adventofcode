const std = @import("std");

const print = std.debug.print;


pub fn main() !void {
    // input "target area: x=128..160, y=-142..-88";
    const xmin: i64 = 128;
    const xmax: i64 = 160;
    const ymin: i64 = -142;
    const ymax: i64 = -88;
    
    // test  "target area: x=20..30, y=-10..-5";
    //~ const xmin: i64 = 20;
    //~ const xmax: i64 = 30;
    //~ const ymin: i64 = -10;
    //~ const ymax: i64 = -5;

    var part1: i64 = 0;
    var part2: i64 = 0;
    
    var yspeed: i64 = ymin; while (yspeed < 1000) : (yspeed += 1) {
    var xspeed: i64 = 1; while (xspeed < 1000) : (xspeed += 1) {
        var x: i64 = 0; var dx = xspeed;
        var y: i64 = 0; var dy = yspeed;
        
        var highest = y;
        
        while (true) {
            x += dx;
            y += dy;
            if (dx > 0) { dx -= 1; }
            dy -= 1;
            if (y > highest) { highest = y; }
            
            // In the zone
            if (xmin <= x and x <= xmax and ymin <= y and y <= ymax) {
                if (highest > part1) { part1 = highest; }
                part2 += 1;
                break;
            }
            
            if (y < ymin) {break;}  // Too low, won't recover
            if (x > xmax) {break;}  // Too far, won't come back
        }
        
    }}
    
    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}


