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
        std::optional<int> keySize;
        std::optional<std::wstring> keyName;

        int getKeySize()
        {
            if (!keySize.has_value())
            {
                keySize.emplace(object.KeyValue(L"KeySize").As<int>());
            }

            return keySize.value();
        }

        std::wstring getKeyName()
        {
            if (!keyName.has_value())
            {
                keyName.emplace(object.KeyValue(L"KeyName").As<std::wstring>());
            }

            return keyName.value();
        }

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object& _object)
            : IDbgEngKeyable<TKey, Dynamic>(_object)
            , keyName(std::nullopt)
            , keySize(std::nullopt)
        {
            //
        }

        int count()
        {
            try
            {
                return object.CallMethod(L"Count").As<int>();
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
                return extensions::AnonBoxer::Unbox(object.CallMethod(L"At", _index, getKeyName(), getKeySize()));
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }

        virtual hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const TKey _key) = 0;
    };

    class LazyIntMap : public LazyMap<int>
    {
    public:
        LazyIntMap(const Debugger::DataModel::ClientEx::Object& _object)
            : LazyMap<int>(_object)
        {
            //
        }

        NativeModelData get(const int _key)
        {
            try
            {
                return object.CallMethod(L"Get", _key, static_cast<unsigned int>(_key)).As<NativeModelData>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }
    };

    class LazyInt64Map : public LazyMap<cpp::Int64>
    {
    public:
        LazyInt64Map(const Debugger::DataModel::ClientEx::Object& _object)
            : LazyMap<cpp::Int64>(_object)
        {
            //
        }

        NativeModelData get(const cpp::Int64 _key)
        {
            try
            {
                return object.CallMethod(L"Get", _key, static_cast<unsigned int>((_key >> 32) ^ _key)).As<NativeModelData>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }
    };
    
    class LazyStringMap : public LazyMap<String>
    {
    public:
        LazyStringMap(const Debugger::DataModel::ClientEx::Object& _object)
            : LazyMap<String>(_object)
        {
            //
        }

        NativeModelData get(const String _key)
        {
            try
            {
                return object.CallMethod(L"Get", std::wstring(_key.wchar_str()), _key.hash()).As<NativeModelData>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }
    };

    class LazyDynamicMap : public LazyMap<DbgEngBaseModel&>
    {
    public:
        LazyDynamicMap(const Debugger::DataModel::ClientEx::Object& _object)
            : LazyMap<DbgEngBaseModel&>(_object)
        {
            //
        }
        NativeModelData get(const DbgEngBaseModel& _key)
        {
            try
            {
                return object.CallMethod(L"Get", _key.object, _key.object.FieldValue(L"__hx_cachedHash")).As<NativeModelData>();
            }
            catch (const std::exception& exn)
            {
                hx::Throw(String::create(exn.what()));
            }
        }
    };
}