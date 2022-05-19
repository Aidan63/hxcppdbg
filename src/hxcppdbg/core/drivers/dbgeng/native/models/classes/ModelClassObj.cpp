#include <hxcpp.h>

#include "models/classes/ModelClassObj.hpp"
#include "models/extensions/Utils.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_sourcemap_GeneratedType
#include <hxcppdbg/core/sourcemap/GeneratedType.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::ModelClassObj(hxcppdbg::core::sourcemap::GeneratedType _type)
    : type(_type), hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(_type->cpp.wc_str())
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto fields = Array<hxcppdbg::core::model::Model>(0, 0);

    for (auto&& kv : object.Fields())
    {
        auto name  = String::create(kv.first.c_str());
        auto key   = hxcppdbg::core::model::ModelData_obj::MString(name);
        auto value = kv.second.GetValue();

        if (value.Type().IsIntrinsic())
        {
            fields.Add(hxcppdbg::core::model::Model_obj::__new(key, hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value)));
        }
        else
        {
            try
            {
                fields.Add(hxcppdbg::core::model::Model_obj::__new(key, value.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>()));
            }
            catch(const std::exception& e)
            {
                // model = hxcppdbg::core::model::ModelData_obj::MUnknown(String::create(value.Type().Name().c_str()));
            }   
        }
    }

    return hxcppdbg::core::model::ModelData_obj::MClass(type, fields);
}