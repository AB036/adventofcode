const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    // Input
    const p1_start: u32 = 7;
    const p2_start: u32 = 3;

    // test
    //~ const p1_start: u32 = 4;
    //~ const p2_start: u32 = 8;
    
    var p1: u32 = p1_start - 1;
    var p2: u32 = p2_start - 1;
    
    var dice: u32 = 0;
    
    var score1: u32 = 0;
    var score2: u32 = 0;
    
    while (true) {
        p1 = (p1 + (dice%100) + 1) % 10;  dice+= 1;
        p1 = (p1 + (dice%100) + 1) % 10;  dice+= 1;
        p1 = (p1 + (dice%100) + 1) % 10;  dice+= 1;
        
        score1 += p1 + 1;
        if (score1 >= 1000) {
            print("Player 1 wins. {} * {} = {}\n\n", .{score2, dice, score2*dice});
            break;
        }
        
        p2 = (p2 + (dice%100) + 1) % 10;  dice+= 1;  
        p2 = (p2 + (dice%100) + 1) % 10;  dice+= 1;  
        p2 = (p2 + (dice%100) + 1) % 10;  dice+= 1;  
        
        score2 += p2 + 1;
        if (score2 >= 1000) {
            print("Player 2 wins. {} * {} = {}\n\n", .{score1, dice, score1*dice});
            break;
        }
    }
    
    
    // {p1, score1, p2, score2} -> n universes with this configuration
    var universe_count = std.AutoHashMap([4]u32, u64).init(allocator);
    try universe_count.put(.{p1_start - 1, 0, p2_start - 1, 0}, 1);
    
    var p1_wins: u64 = 0;
    var p2_wins: u64 = 0;

    const magic = [_]u64 {1, 3, 6, 7, 6, 3, 1};

    var stop = false;
    while (!stop) {
        var new_count = std.AutoHashMap([4]u32, u64).init(allocator);
        stop = true;
        
        var ite = universe_count.iterator();
        while (ite.next()) |kv| {
            const pos1 = kv.key_ptr[0];  const sco1 = kv.key_ptr[1];
            const pos2 = kv.key_ptr[2];  const sco2 = kv.key_ptr[3];
            const uni_count = kv.value_ptr.*;
            
            for (magic) |magic1, k1| {
                const new_pos1: u32 = @intCast(u32, pos1 + k1 + 3) % 10;
                const new_sco1 = sco1 + new_pos1 + 1;
                
                if (new_sco1 >= 21) { p1_wins += uni_count * magic1; }
                else { for (magic) |magic2, k2| {
                    const new_pos2: u32 = @intCast(u32, pos2 + k2 + 3) % 10;
                    const new_sco2 = sco2 + new_pos2 + 1;
                    
                    if (new_sco2 >= 21) { p2_wins += uni_count * magic1 * magic2; }
                    else {
                        const old_val = new_count.get(.{new_pos1, new_sco1, new_pos2, new_sco2}) orelse 0;
                        try new_count.put(
                            .{new_pos1, new_sco1, new_pos2, new_sco2},
                            old_val + uni_count * magic1 * magic2
                        );
                        stop = false;
                    }
                    
                }}
            }
        }
        
        universe_count.deinit();
        universe_count = new_count;
    }
    
    print("Player 1 wins in {} uiverses\n", .{p1_wins});
    print("Player 2 wins in {} uiverses\n", .{p2_wins});
}


