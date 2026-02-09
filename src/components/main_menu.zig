const c = @cImport({
    @cInclude("dcimgui.h");
});

pub const MainMenu = struct {
    const Self = @This();
    show_new_solve_window: bool,
    show_credits_window: bool,

    pub fn init() Self {
        return .{
            .show_new_solve_window = false,
            .show_credits_window = false,
        };
    }

    pub fn draw(self: *Self) void {
        const io = c.ImGui_GetIO();

        if (io.*.KeyAlt) {
            if (c.ImGui_IsKeyPressed(c.ImGuiKey_N)) self.show_new_solve_window = !self.show_new_solve_window;
            if (c.ImGui_IsKeyPressed(c.ImGuiKey_C)) self.show_credits_window = !self.show_credits_window;
        }

        _ = c.ImGui_BeginMainMenuBar();
        if (c.ImGui_MenuItem("New Solve")) self.show_new_solve_window = !self.show_new_solve_window;
        if (c.ImGui_MenuItem("Credits")) self.show_credits_window = !self.show_credits_window;
        c.ImGui_EndMainMenuBar();
    }
};
