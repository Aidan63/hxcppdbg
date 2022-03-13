#include "hxcpp.h"
#include "DbgEngObjects.hpp"
#include "DbgModelClientEx.hpp"

IDataModelManager* Debugger::DataModel::ClientEx::GetManager()
{
    return hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::manager;
}

IDebugHost* Debugger::DataModel::ClientEx::GetHost()
{
    return hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::host;
}