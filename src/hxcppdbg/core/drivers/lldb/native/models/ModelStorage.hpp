#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBValue.h>
#include <SBTypeSummary.h>
#include <SBStream.h>

HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)
HX_DECLARE_CLASS3(hxcppdbg, core, sourcemap, GeneratedType)

namespace hxcppdbg::core::drivers::lldb::native::models
{
    extern hx::Object** currentModel;
    extern hx::Object** classLookup;
    extern hx::Object** enumLookup;

    hxcppdbg::core::model::ModelData valueAsModel(::lldb::SBValue);

    hxcppdbg::core::sourcemap::GeneratedType findClassFor(std::string);
    hxcppdbg::core::sourcemap::GeneratedType findEnumFor(std::string);

    bool setObjectPtrHxcppdbgModelData(::lldb::SBValue, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream&);
}