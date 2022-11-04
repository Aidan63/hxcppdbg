#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template <class TKey>
    class LazyMap : public IDbgEngKeyable<TKey>
    {
    private:
        Debugger::DataModel::ClientEx::Object map;

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object& _object)
            : map(Debugger::DataModel::ClientEx::Object(_object))
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

        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int _index)
        {
            try
            {
                return map.CallMethod(L"At", _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
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
    class LazyMap<String> : public IDbgEngKeyable<String>
    {
    private:
        Debugger::DataModel::ClientEx::Object map;

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object& _object)
            : map(Debugger::DataModel::ClientEx::Object(_object))
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

        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int _index)
        {
            try
            {
                return map.CallMethod(L"At", _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
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
}