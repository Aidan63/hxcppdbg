#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <iostream>
#include <memory>
#include <comdef.h>
#include <string>
#include <array>
#include <vector>
#include <Windows.h>
#include <DbgEng.h>
#include <DbgModel.h>
#include "DbgModelClientEx.hpp"
#include "DebugEventCallbacks.hpp"
#include "RawStackFrame.hpp"
#include "RawFrameLocal.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, DbgEngObjects)
HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, utils, HResultException)
HX_DECLARE_CLASS3(hxcppdbg, core, ds, Result)
HX_DECLARE_CLASS2(haxe, ds, Option)

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngObjects_obj : public hx::Object
    {
    private:
        PDEBUG_CLIENT7 client;
        PDEBUG_CONTROL control;
        PDEBUG_SYMBOLS5 symbols;
        PDEBUG_SYSTEM_OBJECTS4 system;
        std::unique_ptr<DebugEventCallbacks> events;
        Dynamic onBreakpointCb;

        DbgEngObjects_obj(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, PDEBUG_SYSTEM_OBJECTS4 _system, std::unique_ptr<DebugEventCallbacks> _events, Dynamic _onBreakpointCb);
    public:
        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif

        hxcppdbg::core::ds::Result createBreakpoint(String file, int line);
        haxe::ds::Option removeBreakpoint(int id);

        Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame>> getCallStack(int _threadID);
        hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame> getFrame(int _thread, int _index);

        Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>> getVariables(int _thread, int _frame);
        Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>> getArguments(int _thread, int _frame);

        void start(int status);
        void step(int thread, int status);

        static hxcppdbg::core::ds::Result createFromFile(String file, Dynamic _onBreakpointCb);
        static IDataModelManager* manager;
        static IDebugHost* host;
    };
}