#include <hxcpp.h>

#include "models/map/elements/ModelIntElement.hpp"
#include "models/LazyMap.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelIntElement::ModelIntElement()
    : ModelElement(L"hx::TIntElement<*>")
{
    //
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelIntElement::checkKey(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _targetKey, const bool)
{
    auto thisAddress = _object.FieldValue(L"key").As<int>();
    auto keyAddress  = _targetKey.As<int>();

    return thisAddress == keyAddress;
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelIntElement::checkHash(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _hash)
{
    return _object.FieldValue(L"hash").As<unsigned int>() == _hash.As<unsigned int>();
}