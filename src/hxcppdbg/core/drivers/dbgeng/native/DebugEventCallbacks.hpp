#pragma once

#include <hxcpp.h>
#include <DbgEng.h>

HX_DECLARE_CLASS4(hxcppdbg, core, drivers, native, DbgEngObjects)

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DebugEventCallbacks : public DebugBaseEventCallbacksWide
    {
    public:
        DebugEventCallbacks();

        STDMETHOD_(ULONG, AddRef)();
        STDMETHOD_(ULONG, Release)();
        STDMETHOD(GetInterestMask)(OUT PULONG mask);

        STDMETHOD(Breakpoint)(_In_ PDEBUG_BREAKPOINT2 bp);
        STDMETHOD(Exception)(_In_ PEXCEPTION_RECORD64 exception, _In_ ULONG firstChance);
        STDMETHOD(CreateProcess)(
            _In_ ULONG64 imageFileHandle,
            _In_ ULONG64 handle,
            _In_ ULONG64 baseOffset,
            _In_ ULONG moduleSize,
            _In_ PCWSTR moduleName,
            _In_ PCWSTR imageName,
            _In_ ULONG checkSum,
            _In_ ULONG timeDateStamp,
            _In_ ULONG64 initialThreadHandle,
            _In_ ULONG64 threadDataOffset,
            _In_ ULONG64 startOffset);
        STDMETHOD(ExitProcess)(_In_ ULONG ExitCode);
    };
}