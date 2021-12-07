const std = @import("std");

const print = std.debug.print;

pub fn read_input(path: []const u8, allocator: *std.mem.Allocator) ![]u64 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    var iterator = std.mem.tokenize(u8, trimmed, ",");

    var list = std.ArrayList(u64).init(allocator);
    while (iterator.next()) |token| {
        try list.append(try std.fmt.parseInt(u64, token, 10));
    }

    return list.toOwnedSlice();
}

pub fn sumInt(n: u64) u64 {
    return n*(n+1)/2;
}

pub fn dumbSolution(input: *[]u64) !void {
    // this is the dumb way, where we find the minimum of the two cost functions
    // by searching the entire search space
    
    const min = std.mem.min(u64, input.*);
    const max = std.mem.max(u64, input.*);
    
    var pos: u64 = min;
    var best_cost: u64 = (max - min + 1) * input.len;
    var best_cost_2: u64 = sumInt(max - min +1) * input.len;
    
    while (pos <= max) : (pos += 1) {
        var cost: u64 = 0;
        var cost2: u64 = 0;
        for (input.*) |crab| {
            cost += if (pos >= crab) (pos - crab) else (crab - pos);
            cost2 += if (pos >= crab) sumInt(pos - crab) else sumInt(crab - pos);
        }
        if (cost < best_cost) { best_cost = cost; }
        if (cost2 < best_cost_2) { best_cost_2 = cost2; }
    }
    
    print("Part 1: {}\n", .{best_cost});
    print("Part 2: {}\n", .{best_cost_2});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var input = try read_input("input.txt", allocator);
    //~ var input = try read_input("test.txt", allocator);

    // Part 1
    // We search min(sum |x - c| for c in input)
    // f'(x) = sum(1 for c > x) - sum(1 for c < x)
    // f'(x) = 0  <=>  card(c < x) = card(c > x)
    // This is achieved by the median
    // Since we search an integer, we can test c_middle or c_middle + 1
    
    std.sort.sort(u64, input, {}, comptime std.sort.asc(u64));
    const middle = input.len / 2;
    var cost_a: u64 = 0; const pos_a = input[middle];
    var cost_b: u64 = 0; const pos_b = input[middle + 1];
    for (input) |crab| {
        cost_a += if (pos_a >= crab) (pos_a - crab) else (crab - pos_a);
        cost_b += if (pos_b >= crab) (pos_b - crab) else (crab - pos_b);
    }
    print("Part 1: {}\n", .{std.math.min(cost_a, cost_b)});
    
    // Part 2
    // We search min(sum d(|x - c| for c in input) with d(n) = n(n+1)/2
    // f(x) = sum (x - c)^2 / 2 + sum |x - c|
    // f'(x) = sum (x - c) + sum (-1, 0 or 1)
    // f'(x) / n = average(x - c) + A, where |A| <= 1
    // f'(x) = 0  => x in [average-1, average+1]
    
    var mean: u64 = 0;
    for (input) |crab| {mean += crab;}
    mean = mean / input.len;
    
    var cost_2a: u64 = 0;
    var cost_2b: u64 = 0;
    for (input) |crab| {
        cost_2a += if (mean >= crab) sumInt(mean - crab) else sumInt(crab - mean);
        cost_2b += if (mean+1 >= crab) sumInt(mean+1 - crab) else sumInt(crab - (mean+1));
    }
    print("Part 2: {}\n", .{std.math.min(cost_2a, cost_2b)});
}


