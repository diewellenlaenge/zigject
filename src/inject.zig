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

// return value is only valid wait is true
pub fn RemoteThread(pid: win.DWORD, path: []const u16, wait: bool) InjectError!u32 {
    const process = threading.OpenProcess(threading.PROCESS_ALL_ACCESS, win.FALSE, pid) orelse return InjectError.OpenProcess;
    defer _ = win32.foundation.CloseHandle(process);

    const pathSize: usize = (path.len + 1) * @sizeOf(std.meta.Child(@TypeOf(path)));
    const buffer = memory.VirtualAllocEx(process, null, pathSize, memory.MEM_COMMIT, memory.PAGE_READWRITE) orelse return InjectError.VirtualAllocEx;
    defer _ = memory.VirtualFreeEx(process, buffer, 0, memory.MEM_RELEASE);

    if (debug.WriteProcessMemory(process, buffer, @ptrCast(*const anyopaque, path), pathSize, null) == win.FALSE) {
        return InjectError.WriteProcessMemory;
    }

    const kernel32 = loader.GetModuleHandleW(L("kernel32.dll")) orelse return InjectError.GetModuleHandleW;
    const loadLibrary = loader.GetProcAddress(kernel32, "LoadLibraryW") orelse return InjectError.GetProcAddress;
    const thread = threading.CreateRemoteThread(process, null, 0, @ptrCast(threading.LPTHREAD_START_ROUTINE, loadLibrary), buffer, 0, null) orelse return InjectError.CreateRemoteThread;

    if (wait) {
        _ = threading.WaitForSingleObject(thread, win.INFINITE);
    }

    var result: u32 = 0;
    if (threading.GetExitCodeThread(thread, &result) == win.FALSE) {
        return InjectError.GetExitCodeThread;
    }

    return result;
}
