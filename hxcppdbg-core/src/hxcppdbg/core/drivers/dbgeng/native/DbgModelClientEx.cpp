#include "hxcpp.h"
#include "DbgEngContext.hpp"
#include "DbgModelClientEx.hpp"

IDataModelManager* Debugger::DataModel::ClientEx::GetManager()
{
    return hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::manager;
}

IDebugHost* Debugger::DataModel::ClientEx::GetHost()
{
    return hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::host;
}