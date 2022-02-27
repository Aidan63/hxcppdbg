#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <memory>
#include <comdef.h>
#include <string>
#include <array>
#include <Windows.h>
#include <DbgEng.h>
#include "DebugEventCallbacks.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngObjects : public hx::Object
    {
    private:
        PDEBUG_CLIENT7 client;
        PDEBUG_CONTROL control;
        PDEBUG_SYMBOLS5 symbols;
        std::unique_ptr<DebugEventCallbacks> events;
        Dynamic onBreakpointCb;

        DbgEngObjects(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, std::unique_ptr<DebugEventCallbacks> _events, Dynamic _onBreakpointCb);
    public:
            void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
            void __Visit(HX_VISIT_PARAMS);
#endif

        hx::Null<int> createBreakpoint(String file, int line);
        bool removeBreakpoint(int id);

        void start();

        static hx::ObjectPtr<DbgEngObjects> createFromFile(String file, Dynamic _onBreakpointCb);
    };
}