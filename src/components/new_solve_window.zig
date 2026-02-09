const std = @import("std");

const StepsPanel = @import("steps_panel.zig").StepsPanel;

const c = @cImport({
    @cInclude("dcimgui.h");
});

pub const NewSolveWindow = struct {
    const Self = @This();
    start_buf: [18]u8,
    end_buf: [18]u8,
    selected_solver: i32,
    steps_panel: StepsPanel,

    pub fn init(steps_panel: StepsPanel) Self {
        return Self{
            .start_buf = [_]u8{0} ** 18,
            .end_buf   = [_]u8{0} ** 18,
            .selected_solver = 0,
            .steps_panel = steps_panel,
        };
    }

    pub fn draw(self: *Self, p_open: *bool, scaling: f32) void {
        if (!p_open.*) return;
        _ = c.ImGui_SetNextWindowSize(.{ .x = 384 * scaling, .y = 256 * scaling }, 0);
        _ = c.ImGui_Begin("New Solve", p_open, c.ImGuiWindowFlags_NoCollapse | c.ImGuiWindowFlags_NoResize);

        _ = c.ImGui_Text("Boards");
        _ = c.ImGui_InputText("Start", &self.start_buf, self.start_buf.len, 0);
        if (c.ImGui_IsItemHovered(0)) {
            _ = c.ImGui_BeginTooltip();
            _ = c.ImGui_Text("3x3 board start position, e.g. 1,2,3,4,5,6,7,8,0");
            c.ImGui_EndTooltip();
        }

        _ = c.ImGui_InputText("End", &self.end_buf, self.end_buf.len, 0);
        if (c.ImGui_IsItemHovered(0)) {
            _ = c.ImGui_BeginTooltip();
            _ = c.ImGui_Text("3x3 board goal position, e.g. 1,2,3,4,5,6,7,8,0");
            c.ImGui_EndTooltip();
        }

        c.ImGui_Separator();
        _ = c.ImGui_Text("Solver");
        const items= [_]u8{
            'B','F','S', 0,
        };

        _ = c.ImGui_Combo("##solver", &self.selected_solver, &items);
        c.ImGui_Separator();

        if (c.ImGui_Button("Solve")) {
            p_open.* = false;
        }
        if (c.ImGui_Button("Cancel")) p_open.* = false;
        c.ImGui_End();
    }
};
