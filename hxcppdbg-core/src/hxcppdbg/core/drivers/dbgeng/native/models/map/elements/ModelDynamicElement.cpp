#include <hxcpp.h>

#include "models/map/elements/ModelDynamicElement.hpp"
#include "models/LazyMap.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelDynamicElement::ModelDynamicElement()
    : ModelElement(L"hx::TDynamicElement<*,*>")
{
    //
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelDynamicElement::checkKey(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _targetKey, const bool _pointer)
{
    auto thisAddress = _object.FieldValue(L"key").FieldValue(L"mPtr").As<uint64_t>();
    auto keyAddress  = _pointer
        ? _targetKey.FieldValue(L"mPtr").As<uint64_t>()
        : _targetKey.GetLocation().GetOffset();

    return thisAddress == keyAddress;
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelDynamicElement::checkHash(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _hash)
{
    return _object.FieldValue(L"hash").As<unsigned int>() == _hash.As<unsigned int>();
}