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
#include "models/IDbgEngKeyable.hpp"
#include "models/LazyLocalStore.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngSession;

    class DbgEngContext
    {
    private:
        static std::optional<cpp::Pointer<DbgEngContext>> cached;
        
        DbgEngContext(
            ComPtr<IDebugClient7>,
            ComPtr<IDebugControl7>,
            ComPtr<IDebugSymbols5>,
            ComPtr<IDebugSystemObjects4>,
            ComPtr<IHostDataModelAccess>,
            ComPtr<IDebugEventCallbacksWide>,
            std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>>);

    public:
        virtual ~DbgEngContext();

        static IDataModelManager* manager;
        static IDebugHost* host;
        static cpp::Pointer<DbgEngContext> get();

        const ComPtr<IDebugClient7> client;
        const ComPtr<IDebugControl7> control;
        const ComPtr<IDebugSymbols5> symbols;
        const ComPtr<IDebugSystemObjects4> system;
        const ComPtr<IHostDataModelAccess> dataModelAccess;
        const ComPtr<IDebugEventCallbacksWide> events;
        const std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>> models;

        cpp::Pointer<DbgEngSession> start(String, Array<Dynamic>, Array<Dynamic>);
    };
}
