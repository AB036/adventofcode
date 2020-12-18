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


pub fn eval1(expr: []const u8) std.fmt.ParseIntError!u64 {
    var depth: u8 = 0;
    var i: usize = expr.len - 1;
    while (true) : (i -= 1) {
        if (expr[i] == ')') {depth += 1;}
        if (expr[i] == '(') {depth -= 1;}
        if (expr[i] == '*' and depth == 0) {
            return (try eval1(expr[0 .. i-1])) * (try eval1(expr[i+2 ..]));
        }
        if (expr[i] == '+' and depth == 0) {
            return (try eval1(expr[0 .. i-1])) + (try eval1(expr[i+2 ..]));
        }
        if (i == 0) {break;}
    }

    if (expr[0] == '(' and expr[expr.len-1] == ')') {
        return try eval1(expr[1 .. expr.len-1]);
    }

    return try std.fmt.parseInt(u64, expr, 10);
}


pub fn eval2(expr: []const u8) std.fmt.ParseIntError!u64 {
    var depth: u8 = 0;
    var i: usize = 0;
    while (i < expr.len) : (i += 1) {
        if (expr[i] == '(') {depth += 1;}
        if (expr[i] == ')') {depth -= 1;}
        if (expr[i] == '*' and depth == 0) {
            return (try eval2(expr[0 .. i-1])) * (try eval2(expr[i+2 ..]));
        }
    }

    depth = 0;
    i = 0;
    while (i < expr.len) : (i += 1) {
        if (expr[i] == '(') {depth += 1;}
        if (expr[i] == ')') {depth -= 1;}
        if (expr[i] == '+' and depth == 0) {
            return (try eval2(expr[0 .. i-1])) + (try eval2(expr[i+2 ..]));
        }
    }

    if (expr[0] == '(' and expr[expr.len-1] == ')') {
        return try eval2(expr[1 .. expr.len-1]);
    }

    return try std.fmt.parseInt(u64, expr, 10);
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var sum1: u64 = 0; var sum2: u64 = 0;
    for (lines) |line| {
        sum1 += try eval1(line);
        sum2 += try eval2(line);
    }
    print("Part 1: {}\nPart2: {}\n", .{sum1, sum2});
}


