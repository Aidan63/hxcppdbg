#include <hxcpp.h>

#include "models/map/elements/ModelStringElement.hpp"
#include "models/LazyMap.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelStringElement::ModelStringElement()
    : ModelElement(L"hx::TStringElement<*>")
{
    //
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelStringElement::checkKey(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _targetKey, const bool _nativeTarget)
{
    auto thisAddress = _object.FieldValue(L"key").KeyValue(L"String").As<std::wstring>();
    auto keyAddress  = _nativeTarget
        ? _targetKey.KeyValue(L"String").As<std::wstring>()
        : _targetKey.As<std::wstring>();

    return thisAddress == keyAddress;
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelStringElement::checkHash(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _hash)
{
    return _object.FieldValue(L"hash").As<unsigned int>() == _hash.As<unsigned int>();
}