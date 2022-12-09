const std = @import("std");
pub const Options = struct {
    pub const IgnoreOptions = struct {
        dirDots: bool = true,
        allDots: bool = true,
        backups: bool = false,
    };
    ignore: IgnoreOptions = .{},
    printAuthor: bool = false,
    escapeSymbols: bool = false,
    blockSize: ?usize = null,
    recursive: bool = false,
};

fn cloneString(val: []const u8, alloc: std.mem.Allocator) !std.ArrayList(u8) {
    var str = std.ArrayList(u8).init(alloc);
    try str.appendSlice(val);
    return str;
}

pub fn run(opts: Options, writer: anytype, alloc: std.mem.Allocator) !void {
    var todoDirs = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer todoDirs.deinit();
    defer for (todoDirs.items) |item| item.deinit();
    try todoDirs.append(try cloneString(".", alloc));
    var cwd = std.fs.cwd();
    while (todoDirs.popOrNull()) |dir| {
        defer dir.deinit();
        var listDir = try cwd.openIterableDir(dir.items, .{});
        defer listDir.close();
        var iter = listDir.iterate();
        if (opts.recursive) {
            try std.fmt.format(writer, "{s}/\n", .{dir.items});
        }
        while (try iter.next()) |val| {
            try std.fmt.format(writer, "{s} ", .{val.name});
            switch (val.kind) {
                .Directory => {
                    var newDir = std.ArrayList(u8).init(alloc);
                    try std.fmt.format(newDir.writer(), "{s}/{s}", .{ dir.items, val.name });
                    errdefer newDir.deinit();
                    try todoDirs.append(newDir);
                },
                else => {},
            }
        }
    }
}
