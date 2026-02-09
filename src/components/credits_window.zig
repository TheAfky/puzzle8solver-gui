const c = @cImport({
    @cInclude("dcimgui.h");
});

pub const CreditsWindow = struct {
    const Self = @This();

    pub fn draw(p_open: *bool, scaling: f32) void {
        if (!p_open.*) return;

        _ = c.ImGui_SetNextWindowSize(.{ .x = 384 * scaling, .y = 256 * scaling }, 0);
        _ = c.ImGui_Begin("Credits", p_open, c.ImGuiWindowFlags_NoCollapse | c.ImGuiWindowFlags_NoResize);

        _ = c.ImGui_SetWindowFontScale(2);
        _ = c.ImGui_Text("Puzzle 8 Solver");
        _ = c.ImGui_SetWindowFontScale(1);
        _ = c.ImGui_Text("- Simple puzzle 8 solver GUI application for my\n  school project.");
        _ = c.ImGui_Text("- Made by TheAfky.");
        _ = c.ImGui_SetWindowFontScale(1.5);
        _ = c.ImGui_Text("Github");
        _ = c.ImGui_SetWindowFontScale(1);
        _ = c.ImGui_TextLinkOpenURL("https://github.com/TheAfky/puzzle8solver-gui");
        _ = c.ImGui_SetWindowFontScale(1.5);
        _ = c.ImGui_Text("Libraries / Credits");
        _ = c.ImGui_SetWindowFontScale(1);
        _ = c.ImGui_TextLinkOpenURL("https://github.com/TheAfky/puzzle8solver");
        _ = c.ImGui_TextLinkOpenURL("https://github.com/tiawl/cimgui.zig");
        _ = c.ImGui_TextLinkOpenURL("https://github.com/ocornut/imgui");
        c.ImGui_End();
    }
};
