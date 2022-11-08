#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"
#include "DbgModelClientEx.hpp"
#include "extensions/AnonBoxer.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template <class TKey>
    class LazyMap : public IDbgEngKeyable<TKey, Dynamic>
    {
    private:
        Debugger::DataModel::ClientEx::Object map;
        std::optional<int> keySize;
        std::optional<std::wstring> keyName;

        int getKeySize()
        {
            if (!keySize.has_value())
            {
                keySize.emplace(map.KeyValue(L"KeySize").As<int>());
            }

            return keySize.value();
        }

        std::wstring getKeyName()
        {
            if (!keyName.has_value())
            {
                keyName.emplace(map.KeyValue(L"KeyName").As<std::wstring>());
            }

            return keyName.value();
        }

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object& _object)
            : map(Debugger::DataModel::ClientEx::Object(_object))
            , keyName(std::nullopt)
            , keySize(std::nullopt)
        {
            //
        }

        int count()
        {
            try
            {
                return map.CallMethod(L"Count").As<int>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }

        Dynamic at(const int _index)
        {
            try
            {
                return extensions::AnonBoxer::Unbox(map.CallMethod(L"At", _index, getKeyName(), getKeySize()));
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }

        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const TKey _key)
        {
            try
            {
                return map.CallMethod(L"Get", _key).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }
    };

    template<>
    class LazyMap<String> : public IDbgEngKeyable<String, Dynamic>
    {
    private:
        Debugger::DataModel::ClientEx::Object map;
        std::optional<int> keySize;

        int getKeySize()
        {
            if (!keySize.has_value())
            {
                keySize.emplace(map.KeyValue(L"KeySize").As<int>());
            }

            return keySize.value();
        }

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object& _object)
            : map(Debugger::DataModel::ClientEx::Object(_object))
            , keySize(std::nullopt)
        {
            //
        }

        int count()
        {
            try
            {
                return map.CallMethod(L"Count").As<int>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }

        Dynamic at(const int _index)
        {
            try
            {
                return extensions::AnonBoxer::Unbox(map.CallMethod(L"At", _index, std::wstring(L"String"), getKeySize()));
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }

        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String _key)
        {
            try
            {
                return map.CallMethod(L"Get", std::wstring(_key.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }
    };

    template<>
    class LazyMap<Location> : public IDbgEngKeyable<Location, Dynamic>
    {
        //
    };
}