const std = @import("std");

const c = @cImport({
    @cInclude("dcimgui.h");
});

pub const SolutionInfoPanel = struct {
    const Self = @This();

    nodes_count: usize,
    steps_count: usize,
    scaling: f32,

    pub fn init(nodes: usize, steps: usize, scaling: f32) Self {
        return Self{
            .nodes_count = nodes,
            .steps_count = steps,
            .scaling = scaling,
        };
    }

    pub fn draw(self: *Self, x: f32, y: f32, w: f32, h: f32) void {
        _ = c.ImGui_SetNextWindowPos(.{ .x = x, .y = y }, 0);
        _ = c.ImGui_SetNextWindowSize(.{ .x = w, .y = h }, 0);

        _ = c.ImGui_BeginChild("InfoPanel", .{ .x = w, .y = h }, 0, 0);

        var buf: [64]u8 = undefined;
        const text_nodes = std.fmt.bufPrintZ(&buf, "nodes: {d}", .{self.nodes_count}) catch unreachable;
        _ = c.ImGui_Text(text_nodes.ptr);

        c.ImGui_SameLine(); // make next text appear right next to the previous
        const text_steps = std.fmt.bufPrintZ(&buf, "steps: {d}", .{self.steps_count}) catch unreachable;
        _ = c.ImGui_Text(text_steps.ptr);

        c.ImGui_EndChild();
    }

    pub fn setCounts(self: *Self, nodes: usize, steps: usize) void {
        self.nodes_count = nodes;
        self.steps_count = steps;
    }
};
