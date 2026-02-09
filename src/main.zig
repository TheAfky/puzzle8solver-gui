const std = @import("std");
const App = @import("app.zig").App;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var scaling: f32 = 1;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args[1..]) |arg| {
        if (std.mem.startsWith(u8, arg, "--scaling=")) {
            const scale_value = arg[10..];
            scaling = std.fmt.parseFloat(f32, scale_value) catch scaling;
        }
    }

    var app = try App.init(allocator, scaling);
    defer app.deinit();
    try app.run();
}
