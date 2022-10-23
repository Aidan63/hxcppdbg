#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"
#include "models/extensions/HxcppdbgModelFactory.hpp"
#include "models/extensions/HxcppdbgModelDataFactory.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)
HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)

namespace Debugger::DataModel::ClientEx::Boxing
{
    template<>
    struct BoxObject<hxcppdbg::core::model::ModelData>
    {
        static Object Box(const hxcppdbg::core::model::ModelData& model)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory::instance->CreateInstance(model);
        }

        static hxcppdbg::core::model::ModelData Unbox(const Object& src)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory::instance->GetStoredInstance(src);
        }
    };

    template<>
    struct BoxObject<hxcppdbg::core::model::Model>
    {
        static Object Box(const hxcppdbg::core::model::Model& model)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory::instance->CreateInstance(model);
        }

        static hxcppdbg::core::model::Model Unbox(const Object& src)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory::instance->GetStoredInstance(src);
        }
    };
}

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyArray
    {
    private:
        cpp::Reference<Debugger::DataModel::ClientEx::Object> array;

    public:
        LazyArray(const Debugger::DataModel::ClientEx::Object&);

        int length() const;
        int elementSize() const;
        hxcppdbg::core::model::ModelData at(const int, const int) const;
    };
    
    class LazyMap
    {
    private:
        const Debugger::DataModel::ClientEx::Object map;

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object);

        int count() const;
        hxcppdbg::core::model::Model child(const int) const;
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