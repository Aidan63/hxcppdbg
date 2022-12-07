#include <hxcpp.h>
#include "DbgEngBaseModel.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::DbgEngBaseModel::DbgEngBaseModel(const Debugger::DataModel::ClientEx::Object& _object)
    : object(Debugger::DataModel::ClientEx::Object(_object))
{
    //
}