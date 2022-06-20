#include <hxcpp.h>

#include "Utils.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object object)
{
    auto type    = object.Type();
	auto kind    = type.IntrinsicKind();
	auto carrier = type.IntrinsicCarrier();

	switch (kind)
	{
		// These intrinsics all have fixed / known sizes

		case IntrinsicKind::IntrinsicBool:
			return hxcppdbg::core::model::ModelData_obj::MBool(object.As<bool>());

		case IntrinsicKind::IntrinsicChar:
			return hxcppdbg::core::model::ModelData_obj::MInt(object.As<char>());

		case IntrinsicKind::IntrinsicWChar:
			return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());

		case IntrinsicKind::IntrinsicHRESULT:
			return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());

		case IntrinsicKind::IntrinsicChar16:
			return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());

		case IntrinsicKind::IntrinsicChar32:
			return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());

		// With these we need to inspect the carrier to find its size

		case IntrinsicKind::IntrinsicInt:
		case IntrinsicKind::IntrinsicLong:
			switch (carrier)
			{
				case VARENUM::VT_I1:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());
				case VARENUM::VT_I2:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());
				case VARENUM::VT_I4:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());
				case VARENUM::VT_I8:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());
				case VARENUM::VT_INT:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<int>());
				default:
					return hxcppdbg::core::model::ModelData_obj::MUnknown(HX_CSTRING("unsupported VARENUM kind"));
			}

		case IntrinsicKind::IntrinsicUInt:
		case IntrinsicKind::IntrinsicULong:
			switch (carrier)
			{
				case VARENUM::VT_UI1:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<unsigned int>());
				case VARENUM::VT_UI2:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<unsigned int>());
				case VARENUM::VT_UI4:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<unsigned int>());
				case VARENUM::VT_UI8:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<unsigned int>());
				case VARENUM::VT_UINT:
					return hxcppdbg::core::model::ModelData_obj::MInt(object.As<unsigned int>());
				default:
					return hxcppdbg::core::model::ModelData_obj::MUnknown(HX_CSTRING("unsupported VARENUM kind"));
			}

		case IntrinsicKind::IntrinsicFloat:
			switch (carrier)
			{
				case VARENUM::VT_R4:
					return hxcppdbg::core::model::ModelData_obj::MFloat(object.As<float>());
				case VARENUM::VT_R8:
					return hxcppdbg::core::model::ModelData_obj::MFloat(object.As<double>());
				default:
					return hxcppdbg::core::model::ModelData_obj::MUnknown(HX_CSTRING("unsupported VARENUM kind"));
			}
			break;

		default:
			return hxcppdbg::core::model::ModelData_obj::MUnknown(HX_CSTRING("unsupported intrinsic kind"));
	}
}