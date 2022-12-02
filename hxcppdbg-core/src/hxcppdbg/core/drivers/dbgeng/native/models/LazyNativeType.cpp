#include <hxcpp.h>
#include "LazyNativeType.hpp"
#include "NativeModelData.hpp"
#include "extensions/Utils.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeType::LazyNativeType(const Debugger::DataModel::ClientEx::Object& _type)
    : size(std::nullopt)
    , fields(std::nullopt)
    , IDbgEngKeyable(_type)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeType::count()
{
    if (!size.has_value())
    {
        auto accumulator = 0;
        for (auto&& _ : object.Fields())
        {
            accumulator++;
        }

        size.emplace(accumulator);
    }

    return size.value();
}

Dynamic hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeType::at(const int _index)
{
    try
    {
        auto count = 0;

        for (auto&& field : object.Fields())
        {
            if (count == _index)
            {
                auto found = std::get<1>(field).GetValue();
                auto type  = String::create(found.Type().Name().c_str());
                auto model = extensions::objectToHxcppdbgModelData(found);
                auto anon  = hx::Anon_obj::Create(2);

                anon->setFixed(0, HX_CSTRING("name"), type);
                anon->setFixed(1, HX_CSTRING("data"), model);

                return anon;
            }

            count++;
        }

        throw std::runtime_error("No field for index");
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeType::get(const String _key)
{
    try
    {
        return extensions::objectToHxcppdbgModelData(object.FieldValue(_key.wchar_str()));
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}