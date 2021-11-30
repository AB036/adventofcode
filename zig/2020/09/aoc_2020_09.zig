const std = @import("std");

const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.split(trimmed, "\n");
    var list = std.ArrayList([]const u8).init(allocator);
    while (iterator.next()) |token| {
        try list.append(token);
    }

    return list.toOwnedSlice();
}


pub fn flat(i: usize, j: usize, N: usize) usize {
    // finicky index stuff to only use the top right half of a N*N square without the diagonal
    if (j < i and i < N) {return i-1-j + N*j - (j*(j+1))/2;}
    if (i < j and j < N) {return j-1-i + N*i - (i*(i+1))/2;}
    unreachable;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);
    const N: usize = 25;

    var list = std.ArrayList(u64).init(allocator);
    for (lines) |line| {
        const a = try std.fmt.parseInt(u64, line, 10);
        try list.append(a);
    }
    var numbers = list.toOwnedSlice();

    // rolling: array with the last N elements
    var rolling = [_]u64{0} ** N;
    var k: usize = 0;
    while (k < N) : (k += 1) { rolling[k] = numbers[k]; }

    // sums: all possible sums of pairs in rolling
    var sums = [_]u64{0} ** ((N*(N-1))/2);
    var i: usize = 0;
    while (i < N) : (i += 1) {
         var j: usize = i + 1;
         while (j < N) : (j += 1) { sums[flat(i,j,N)] = rolling[i] + rolling[j]; }
    }

    var i_roll: usize = 0;
    while (k < numbers.len) : (k += 1) {
        for (sums) |sum| { 
            if (numbers[k] == sum) {break;}
        }
        else { break; } // no sum matched the number, exit 

        rolling[i_roll] = numbers[k];
        var j: usize = 0;
        while (j < N) : (j += 1) {
            if (i_roll != j) {sums[flat(i_roll,j,N)] = rolling[i_roll] + rolling[j];}
        }
        i_roll = (i_roll + 1) % N;
    }

    // catterpillar algorithm (thanks /g/)
    var sum_total: u64 = 0;
    var range_begin: usize = 0;
    var range_end: usize = 0;
    while (range_end < numbers.len) : (range_end += 1) {
        sum_total += numbers[range_end];
        while (sum_total > numbers[k]) {
            sum_total -= numbers[range_begin];
            range_begin += 1;
        }
        if (range_end >= range_begin + 1 and sum_total == numbers[k]) { break; }
    }

    var mini = numbers[range_begin];
    var maxi = mini;
    for (numbers[range_begin .. range_end+1]) |number| {
        mini = std.math.min(mini, number);
        maxi = std.math.max(maxi, number);
    }
    print("Part 1: {}\n", .{numbers[k]});
    print("Part 2: {} + {} = {}\n", .{mini, maxi, mini + maxi});
}


