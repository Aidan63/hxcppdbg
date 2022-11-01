#include <hxcpp.h>
#include "LazyLocalStore.hpp"
#include "NativeModelData.hpp"
#include "models/extensions/Utils.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::LazyLocalStore(
    Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata> _fields)
        : fields(_fields)
{
    //
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::local(String _name)
{
    try
    {
        auto object = fields[_name.wchar_str()].GetValue();
        auto type   = object.Type();

        return
            type.IsIntrinsic()
                ? extensions::intrinsicObjectToHxcppdbgModelData(object)
                : object.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

Array<String> hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore::locals()
{
    try
    {
        auto names = Array<String>(0, 0);

        for (auto&& t : fields)
        {
            names->push(String::create(std::get<0>(t).c_str()));
        }

        return names;
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}