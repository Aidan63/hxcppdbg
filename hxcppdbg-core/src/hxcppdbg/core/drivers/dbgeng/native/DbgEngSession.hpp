#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"
#include "models/LazyLocalStore.hpp"
#include "DebugEventCallbacks.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngContext;

    class DbgEngSession
    {
    private:
        cpp::Pointer<DbgEngContext> ctx;
        std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>> models;
        ULONG stepOutBreakpointId;

        Dynamic readFrame(const Debugger::DataModel::ClientEx::Object&);
        NativeModelData tryFindThrownObject(int);

        static String cleanFunctionName(const std::wstring&);
        static int backtickCount(const std::wstring&);
        static bool endsWith(const std::wstring&, const std::wstring&);
    public:
        DbgEngSession(
            cpp::Pointer<DbgEngContext>,
            std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>>);

        int64_t createBreakpoint(String, int);
        void removeBreakpoint(int64_t);

        Array<int> getThreads();
        Array<Dynamic> getCallStack(int);
        Dynamic getFrame(int, int);

        cpp::Pointer<models::IDbgEngKeyable<String, NativeNamedModelData>> getVariables(int, int);
        cpp::Pointer<models::IDbgEngKeyable<String, NativeNamedModelData>> getArguments(int, int);

        void go();
        void step(int, int);
        void end();

        bool interrupt();
        void wait(Dynamic, Dynamic, Dynamic, Dynamic, Dynamic, Dynamic);
    };
}