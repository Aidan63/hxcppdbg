#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <memory>
#include <comdef.h>
#include <string>
#include <array>
#include <vector>
#include <Windows.h>
#include <DbgEng.h>
#include "DebugEventCallbacks.hpp"
#include "RawStackFrame.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngObjects : public hx::Object
    {
    private:
        PDEBUG_CLIENT7 client;
        PDEBUG_CONTROL control;
        PDEBUG_SYMBOLS5 symbols;
        PDEBUG_SYSTEM_OBJECTS4 system;
        std::unique_ptr<DebugEventCallbacks> events;
        Dynamic onBreakpointCb;

        DbgEngObjects(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, PDEBUG_SYSTEM_OBJECTS4 _system, std::unique_ptr<DebugEventCallbacks> _events, Dynamic _onBreakpointCb);
    public:
        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif

        hx::Null<int> createBreakpoint(String file, int line);
        bool removeBreakpoint(int id);

        Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame>> getCallStack(int _threadID);

        hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame> getFrame(int _thread, int _index);

        void start(int status);
        void step(int thread, int status);

        static hx::ObjectPtr<DbgEngObjects> createFromFile(String file, Dynamic _onBreakpointCb);
    };
}