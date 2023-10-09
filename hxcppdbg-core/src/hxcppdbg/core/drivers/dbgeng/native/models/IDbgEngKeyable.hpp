#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngIndexable.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)
HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeNamedModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template <class TKey, class TValue>
    class IDbgEngKeyable : public IDbgEngIndexable<TValue>
    {
    public:
        IDbgEngKeyable(const Debugger::DataModel::ClientEx::Object& _object)
            : IDbgEngIndexable(_object)
        {
            //
        }

        virtual hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const TKey) = 0;
    };
}