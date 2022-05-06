#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBValue.h>
#include <SBStream.h>

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)
HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)

namespace hxcppdbg::core::drivers::lldb::native
{
    class TypeConverters
    {
    public:
        static String readString(::lldb::SBValue value);

        static hxcppdbg::core::model::ModelData convertValue(::lldb::SBValue value);

        static hxcppdbg::core::model::ModelData valueAsString(::lldb::SBValue value);

        static hxcppdbg::core::model::ModelData valueAsDynamic(::lldb::SBValue value);

        static hxcppdbg::core::model::ModelData valueAsArray(::lldb::SBValue value);

        static hxcppdbg::core::model::ModelData valueAsVariant(::lldb::SBValue value);

        static hxcppdbg::core::model::ModelData valueAsEnum(::lldb::SBValue value);
    };
}