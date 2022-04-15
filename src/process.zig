const std = @import("std");
const win = std.os.windows;
const win32 = @import("lib/zigwin32/win32.zig");
const tool_help = win32.system.diagnostics.tool_help;
const foundation = win32.foundation;

pub const ProcessError = error {
    CreateToolhelp32Snapshot,
    Process32FirstW,
    ProcessNotFound
};

// process_name is case sensitive (for now)
pub fn FindFirstProcessIdByName(process_name: []const u16) ProcessError!win.DWORD {
    const snapshot = tool_help.CreateToolhelp32Snapshot(tool_help.TH32CS_SNAPPROCESS, 0) orelse return ProcessError.CreateToolhelp32Snapshot;
    if (snapshot == win.INVALID_HANDLE_VALUE) {
        return ProcessError.CreateToolhelp32Snapshot;
    }
    defer _ = foundation.CloseHandle(snapshot);

    var pe = tool_help.PROCESSENTRY32W{
        .dwSize = @sizeOf(tool_help.PROCESSENTRY32W),
        .cntUsage = 0,
        .th32ProcessID = 0,
        .th32DefaultHeapID = 0,
        .th32ModuleID = 0,
        .cntThreads = 0,
        .th32ParentProcessID = 0,
        .pcPriClassBase = 0,
        .dwFlags = 0,
        .szExeFile = undefined,
    };

    var ret = tool_help.Process32FirstW(snapshot, &pe);
    if (ret == win.FALSE) {
        return ProcessError.Process32FirstW;
    }

    while (ret == win.TRUE) : (ret = tool_help.Process32NextW(snapshot, &pe)) {
        if (std.mem.eql(u16, std.mem.sliceTo(pe.szExeFile[0..], 0), process_name)) {
            return pe.th32ProcessID;
        }
    }

    return ProcessError.ProcessNotFound;
}
