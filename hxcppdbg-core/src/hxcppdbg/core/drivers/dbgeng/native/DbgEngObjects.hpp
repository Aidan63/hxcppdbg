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
#include <atomic>
#include "DbgModelClientEx.hpp"
#include "DebugEventCallbacks.hpp"

HX_DECLARE_CLASS2(haxe, ds, Option)
HX_DECLARE_CLASS3(hxcppdbg, core, ds, Result)
HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)
HX_DECLARE_CLASS3(hxcppdbg, core, drivers, StopReason)
HX_DECLARE_CLASS4(hxcppdbg, core, drivers, dbgeng, NativeFrameReturn)
HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, DbgEngObjects)
HX_DECLARE_CLASS3(hxcppdbg, core, sourcemap, GeneratedType)

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngObjects_obj : public hx::Object
    {
    private:
        ComPtr<IDebugClient7> client;
        ComPtr<IDebugControl7> control;
        ComPtr<IDebugSymbols5> symbols;
        ComPtr<IDebugSystemObjects4> system;
        std::unique_ptr<DebugEventCallbacks> events;
        std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>> models;
        std::atomic_bool pauseRequested;

        DbgEngObjects_obj(
            ComPtr<IDebugClient7> _client,
            ComPtr<IDebugControl7> _control,
            ComPtr<IDebugSymbols5> _symbols,
            ComPtr<IDebugSystemObjects4> _system,
            std::unique_ptr<DebugEventCallbacks> _events,
            Array<hxcppdbg::core::sourcemap::GeneratedType> enums,
            Array<hxcppdbg::core::sourcemap::GeneratedType> classes);

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
        haxe::ds::Option pause();

        haxe::ds::Option end();

        static hxcppdbg::core::ds::Result createFromFile(String file, Array<hxcppdbg::core::sourcemap::GeneratedType> enums, Array<hxcppdbg::core::sourcemap::GeneratedType> classes);
        static IDataModelManager* manager;
        static IDebugHost* host;
    };
}