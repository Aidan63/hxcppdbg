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
HX_DECLARE_CLASS4(hxcppdbg, core, drivers, dbgeng, NativeFrameReturn)
HX_DECLARE_CLASS3(hxcppdbg, core, ds, Result)
HX_DECLARE_CLASS2(haxe, ds, Option)
HX_DECLARE_CLASS3(hxcppdbg, core, drivers, StopReason)

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

        DbgEngObjects_obj(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, PDEBUG_SYSTEM_OBJECTS4 _system, std::unique_ptr<DebugEventCallbacks> _events);

        hxcppdbg::core::drivers::dbgeng::NativeFrameReturn nativeFrameFromDebugFrame(const Debugger::DataModel::ClientEx::Object& frame);

        static String cleanSymbolName(std::wstring _input);
        static int backtickCount(std::wstring _input);
        static bool endsWith(std::wstring const &_input, std::wstring const &_ending);

        hxcppdbg::core::ds::Result processLastEvent();

    public:
        hxcppdbg::core::ds::Result createBreakpoint(String file, int line);
        haxe::ds::Option removeBreakpoint(int id);

        hxcppdbg::core::ds::Result getCallStack(int _threadID);
        hxcppdbg::core::ds::Result getFrame(int _thread, int _index);

        hxcppdbg::core::ds::Result getVariables(int _thread, int _frame);
        hxcppdbg::core::ds::Result getArguments(int _thread, int _frame);

        hxcppdbg::core::ds::Result start(int status);
        hxcppdbg::core::ds::Result step(int thread, int status);

        static hxcppdbg::core::ds::Result createFromFile(String file);
        static IDataModelManager* manager;
        static IDebugHost* host;
    };
}