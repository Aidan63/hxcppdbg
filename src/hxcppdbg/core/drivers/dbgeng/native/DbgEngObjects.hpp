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

        DbgEngObjects(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, std::unique_ptr<DebugEventCallbacks> _events);
    public:
        hx::Null<int> createBreakpoint(String file, int line);
        bool removeBreakpoint(int id);

        void start();

        static hx::ObjectPtr<DbgEngObjects> createFromFile(String file);
    };
}