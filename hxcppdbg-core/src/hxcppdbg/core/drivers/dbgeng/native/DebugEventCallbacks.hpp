#pragma once

#include <hxcpp.h>
#include <DbgEng.h>

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DebugEventCallbacks : public DebugBaseEventCallbacksWide
    {
    public:
        DebugEventCallbacks();

        STDMETHOD_(ULONG, AddRef)();
        STDMETHOD_(ULONG, Release)();
        STDMETHOD(GetInterestMask)(OUT PULONG mask);

        STDMETHOD(Breakpoint)(PDEBUG_BREAKPOINT2 bp);
        STDMETHOD(Exception)(PEXCEPTION_RECORD64 exception, ULONG firstChance);
        STDMETHOD(CreateThread)(ULONG64 Handle, ULONG64 DataOffset, ULONG64 StartOffset);
        STDMETHOD(ExitThread)(ULONG ExitCode);
        STDMETHOD(CreateProcess)(
            ULONG64 ImageFileHandle,
            ULONG64 Handle,
            ULONG64 BaseOffset,
            ULONG ModuleSize,
            PCWSTR ModuleName,
            PCWSTR ImageName,
            ULONG CheckSum,
            ULONG TimeDateStamp,
            ULONG64 InitialThreadHandle,
            ULONG64 ThreadDataOffset,
            ULONG64 StartOffset);
        STDMETHOD(ExitProcess)(ULONG ExitCode);
    };
}