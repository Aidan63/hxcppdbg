#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/map/elements/ModelElement.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map::elements
{
    class ModelStringElement : public ModelElement
    {
    public:
        ModelStringElement();

        bool checkHash(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object);
        bool checkKey(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object, const bool);
    };
}