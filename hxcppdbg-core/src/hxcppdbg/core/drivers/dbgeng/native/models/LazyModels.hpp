#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyArray
    {
    private:
        Debugger::DataModel::ClientEx::Object array;

    public:
        LazyArray(const Debugger::DataModel::ClientEx::Object&);

        int length() const;
        int elementSize() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int, const int) const;
    };
    
    class LazyMap
    {
    private:
        cpp::Reference<Debugger::DataModel::ClientEx::Object> map;

    public:
        LazyMap();
        LazyMap(const Debugger::DataModel::ClientEx::Object&);
        LazyMap(const LazyMap&);
        LazyMap& operator=(const LazyMap&);

        int count() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData child(const int) const;
    };

    class LazyAnon
    {
    private:
        const Debugger::DataModel::ClientEx::Object anon;

    public:
        LazyAnon(const Debugger::DataModel::ClientEx::Object);
    };

    class LazyEnum
    {
        //
    };

    class LazyClass
    {
        //
    };
}