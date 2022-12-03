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

        STDMETHOD(Breakpoint)(_In_ PDEBUG_BREAKPOINT2 bp);
        STDMETHOD(Exception)(_In_ PEXCEPTION_RECORD64 exception, _In_ ULONG firstChance);
    };
}