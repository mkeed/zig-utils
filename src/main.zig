const std = @import("std");
const ls = @import("ls.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    while (args.next()) |arg| {
        std.log.info("|{s}|", .{arg});
    }
    var stdout = std.io.getStdOut();
    try ls.run(
        .{ .recursive = true },
        stdout.writer(),
        alloc,
    );
}
