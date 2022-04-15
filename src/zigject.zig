const std = @import("std");
const L = std.unicode.utf8ToUtf16LeStringLiteral;
const heap = std.heap;

const win = std.os.windows;
const win32 = @import("lib/zigwin32/win32.zig");
const threading = win32.system.threading;
const memory = win32.system.memory;
const debug = win32.system.diagnostics.debug;
const loader = win32.system.library_loader;
const foundation = win32.foundation;

pub const RemoteThreadError = error {
    OpenProcess,
    VirtualAllocEx,
    WriteProcessMemory,
    GetModuleHandleW,
    GetProcAddress,
    CreateRemoteThread,
    utf8ToUtf16LeWithNull,
};

pub fn RemoteThread(pid: win.DWORD, path: []const u8) RemoteThreadError!bool {
    const process = threading.OpenProcess(threading.PROCESS_ALL_ACCESS, win.FALSE, pid) orelse return RemoteThreadError.OpenProcess;
    defer _= win32.foundation.CloseHandle(process);

    var gpa = heap.GeneralPurposeAllocator(.{}){};
    var galloc = gpa.allocator();

    const pathW = std.unicode.utf8ToUtf16LeWithNull(galloc, path) catch return RemoteThreadError.utf8ToUtf16LeWithNull;
    defer galloc.free(pathW);
    const pathSize: usize = (pathW.len + 1) * @sizeOf(std.meta.Child(@TypeOf(pathW)));

    const buffer = memory.VirtualAllocEx(process, null, pathSize, memory.MEM_COMMIT, memory.PAGE_READWRITE) orelse return RemoteThreadError.VirtualAllocEx;
    defer _ = memory.VirtualFreeEx(process, buffer, 0, memory.MEM_RELEASE);

    if (debug.WriteProcessMemory(process, buffer, @ptrCast(*const anyopaque, pathW), pathSize, null) == win.FALSE) {
        return RemoteThreadError.WriteProcessMemory;
    }

    const kernel32 = loader.GetModuleHandleW(L("kernel32.dll")) orelse return RemoteThreadError.GetModuleHandleW;
    const loadLibrary = loader.GetProcAddress(kernel32, "LoadLibraryW") orelse return RemoteThreadError.GetProcAddress;
    const thread = threading.CreateRemoteThread(process, null, 0, @ptrCast(threading.LPTHREAD_START_ROUTINE, loadLibrary), buffer, 0, null) orelse return RemoteThreadError.CreateRemoteThread;

    _ = threading.WaitForSingleObject(thread, win.INFINITE);

    return true;
}
