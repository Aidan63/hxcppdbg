#include <hxcpp.h>
#include <iterator>
#include "LazyLocalStore.hpp"
#include "NativeModelData.hpp"
#include "models/extensions/Utils.hpp"
#include "extensions/AnonBoxer.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::LazyLocalStore(const Debugger::DataModel::ClientEx::Object& _object)
    : IDbgEngKeyable<String, Dynamic>(_object)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::count()
{
    auto count = 0;

    for (auto&& _ : object.Keys())
    {
        count++;
    }

    return count;
}

Dynamic hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::at(const int _index)
{
    try
    {
        auto count = 0;

        for (auto&& field : object.Keys())
        {
            if (count == _index)
            {
                auto name    = String::create(std::get<0>(field).c_str());
                auto dataObj = std::get<1>(field).GetValue();
                auto data    = extensions::objectToHxcppdbgModelData(dataObj);

                auto anon = hx::Anon_obj::Create(2);

                anon->setFixed(0, HX_CSTRING("name"), name);
                anon->setFixed(1, HX_CSTRING("data"), data);

                return anon;
            }

            count++;
        }

        throw std::runtime_error("Failed to find object for index");
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::get(const String _name)
{
    try
    {
        auto field = object.KeyValue(_name.wchar_str());
        auto type  = field.Type();

        return
            type.IsIntrinsic()
                ? extensions::intrinsicObjectToHxcppdbgModelData(field)
                : field.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}