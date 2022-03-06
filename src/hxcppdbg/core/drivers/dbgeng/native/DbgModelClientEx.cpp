#include "hxcpp.h"

#include "DbgModelClientEx.hpp"

IDataModelManager* Debugger::DataModel::ClientEx::GetManager()
{
    return hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::manager;
}

IDebugHost* Debugger::DataModel::ClientEx::GetHost()
{
    return hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::host;
}