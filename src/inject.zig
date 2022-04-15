const std = @import("std");
const L = std.unicode.utf8ToUtf16LeStringLiteral;

const win = std.os.windows;
const win32 = @import("lib/zigwin32/win32.zig");
const threading = win32.system.threading;
const memory = win32.system.memory;
const debug = win32.system.diagnostics.debug;
const loader = win32.system.library_loader;
const foundation = win32.foundation;

pub const InjectError = error {
    OpenProcess,
    VirtualAllocEx,
    WriteProcessMemory,
    GetModuleHandleW,
    GetProcAddress,
    CreateRemoteThread,
    GetExitCodeThread,
};

/// return value is only valid if wait is true
pub fn RemoteThread(process_id: win.DWORD, path: []const u16, wait: bool) InjectError!u32 {
    const process = threading.OpenProcess(threading.PROCESS_ALL_ACCESS, win.FALSE, process_id) orelse return InjectError.OpenProcess;
    defer _ = foundation.CloseHandle(process);

    const path_size: usize = (path.len + 1) * @sizeOf(std.meta.Child(@TypeOf(path)));
    const buffer = memory.VirtualAllocEx(process, null, path_size, memory.MEM_COMMIT, memory.PAGE_READWRITE) orelse return InjectError.VirtualAllocEx;
    defer _ = memory.VirtualFreeEx(process, buffer, 0, memory.MEM_RELEASE);

    if (debug.WriteProcessMemory(process, buffer, @ptrCast(*const anyopaque, path), path_size, null) == win.FALSE) {
        return InjectError.WriteProcessMemory;
    }

    const kernel32 = loader.GetModuleHandleW(L("kernel32.dll")) orelse return InjectError.GetModuleHandleW;
    const load_library = loader.GetProcAddress(kernel32, "LoadLibraryW") orelse return InjectError.GetProcAddress;
    const thread = threading.CreateRemoteThread(process, null, 0, @ptrCast(threading.LPTHREAD_START_ROUTINE, load_library), buffer, 0, null) orelse return InjectError.CreateRemoteThread;

    if (wait) {
        _ = threading.WaitForSingleObject(thread, win.INFINITE);
    }

    var result: u32 = 0;
    if (threading.GetExitCodeThread(thread, &result) == win.FALSE) {
        return InjectError.GetExitCodeThread;
    }

    return result;
}
