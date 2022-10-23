#include <hxcpp.h>
#include "LazyModels.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

using namespace Debugger::DataModel::ClientEx;

//

hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::LazyArray(const Object& _object)
    : array(_object)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::length() const
{
    return array->CallMethod(L"Length").As<int>();
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::elementSize() const
{
    return array->CallMethod(L"ElementSize").As<int>();
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::at(const int _elementSize, const int _index) const
{
    return array->CallMethod(L"At", _elementSize, _index).As<hxcppdbg::core::model::ModelData>();
}

//

hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::LazyMap(const Object _object)
    : map(_object)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::count() const
{
    return map.CallMethod(L"Count").As<int>();
}

hxcppdbg::core::model::Model hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::child(const int _index) const
{
    return map.CallMethod(L"At").As<hxcppdbg::core::model::Model>();
}