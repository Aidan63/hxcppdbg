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
#include <sstream>
#include <Windows.h>
#include <DbgEng.h>
#include <DbgModel.h>
#include "DbgModelClientEx.hpp"
#include "DebugEventCallbacks.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, DbgEngObjects)
HX_DECLARE_CLASS3(hxcppdbg, core, stack, NativeFrame)
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

        hxcppdbg::core::stack::NativeFrame nativeFrameFromDebugFrame(const Debugger::DataModel::ClientEx::Object& frame);

        static String cleanSymbolName(std::wstring _input);
        static int backtickCount(std::wstring _input);
        static bool endsWith(std::wstring const &_input, std::wstring const &_ending);
    public:
        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif

        hxcppdbg::core::ds::Result createBreakpoint(String file, int line);
        haxe::ds::Option removeBreakpoint(int id);

        hxcppdbg::core::ds::Result getCallStack(int _threadID);
        hxcppdbg::core::ds::Result getFrame(int _thread, int _index);

        hxcppdbg::core::ds::Result getVariables(int _thread, int _frame);
        hxcppdbg::core::ds::Result getArguments(int _thread, int _frame);

        haxe::ds::Option start(int status);
        haxe::ds::Option step(int thread, int status);

        static hxcppdbg::core::ds::Result createFromFile(String file, Dynamic _onBreakpointCb);
        static IDataModelManager* manager;
        static IDebugHost* host;
    };
}