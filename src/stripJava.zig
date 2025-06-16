// const rawString = @embedFile("javap_output");
const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const rawString = args[1];

    var lineIter = std.mem.splitScalar(u8, rawString, '\n');
    const stdout = std.io.getStdOut();

    while (lineIter.next()) |line| {
        if(line.len == 0) continue;
        if(line[0] != ' ') continue;
        const beginType: usize = std.mem.indexOf(u8, line, "java.lang.String ") orelse continue;
        const beginConst: usize = beginType + "java.lang.String ".len;
        const endConst: usize = std.mem.indexOfScalar(u8, line[beginConst..], ';') orelse std.debug.panic("bad const: {s}\n", .{line});
        try stdout.writeAll(line[beginConst..][0..endConst]);
        try stdout.writeAll("\n");
    }
}

pub fn strip(input: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var lineIter = std.mem.splitScalar(u8, input, '\n');
    var output = std.ArrayList(u8).init(allocator);
    while (lineIter.next()) |line| {
        if(line.len == 0) continue;
        if(line[0] != ' ') continue;
        const beginType: usize = std.mem.indexOf(u8, line, "java.lang.String ") orelse continue;
        const beginConst: usize = beginType + "java.lang.String ".len;
        const endConst: usize = std.mem.indexOfScalar(u8, line[beginConst..], ';') orelse std.debug.panic("bad const: {s}\n", .{line});

        try output.appendSlice(line[beginConst..][0..endConst]);
        try output.appendSlice("\n");
    }
    return try output.toOwnedSlice();
}
