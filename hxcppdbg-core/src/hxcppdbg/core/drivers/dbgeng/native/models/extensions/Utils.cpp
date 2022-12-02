#include <hxcpp.h>

#include "Utils.hpp"
#include <vector>

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::extensions::objectToHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
	auto type = object.Type();

	switch (type.GetKind())
	{
		case TypeKind::TypeUDT:
			{
				if (object.HasKey(L"HxcppdbgModelData"))
				{
					try
					{
						return object.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
					}
					catch (const std::exception&)
					{
						return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
					}
				}
				else
				{
					return NativeModelData_obj::NNull();	
				}
			}
		case TypeKind::TypeArray:
			{
				auto name      = type.BaseType().Name();
				auto dimension = *type.ArrayDimensions().begin();

				return NativeModelData_obj::NArray(new LazyNativeArray(object, name, dimension.Length));
			}
			break;
		case TypeKind::TypePointer:
		case TypeKind::TypeMemberPointer:
			{
				auto address      = object.As<uint64_t>();
				auto dereferenced = address == NULL
					? NativeModelData_obj::NNull()
					: objectToHxcppdbgModelData(object.Dereference().GetValue().TryCastToRuntimeType());

				return NativeModelData_obj::NPointer(address, dereferenced);
			}
		case TypeKind::TypeIntrinsic:
			return intrinsicObjectToHxcppdbgModelData(object);
		default:
			return NativeModelData_obj::NNull();
	}
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
	auto type    = object.Type();
	auto kind    = type.IntrinsicKind();
	auto carrier = type.IntrinsicCarrier();

	switch (kind)
	{
		// These intrinsics all have fixed / known sizes

		case IntrinsicKind::IntrinsicBool:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NBool(object.As<bool>());

		case IntrinsicKind::IntrinsicChar:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<char>());

		case IntrinsicKind::IntrinsicWChar:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());

		case IntrinsicKind::IntrinsicHRESULT:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());

		case IntrinsicKind::IntrinsicChar16:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());

		case IntrinsicKind::IntrinsicChar32:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());

		// With these we need to inspect the carrier to find its size

		case IntrinsicKind::IntrinsicInt:
		case IntrinsicKind::IntrinsicLong:
			switch (carrier)
			{
				case VARENUM::VT_I1:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());
				case VARENUM::VT_I2:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());
				case VARENUM::VT_I4:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());
				case VARENUM::VT_I8:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());
				case VARENUM::VT_INT:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<int>());
				default:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
			}

		case IntrinsicKind::IntrinsicUInt:
		case IntrinsicKind::IntrinsicULong:
			switch (carrier)
			{
				case VARENUM::VT_UI1:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<unsigned int>());
				case VARENUM::VT_UI2:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<unsigned int>());
				case VARENUM::VT_UI4:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<unsigned int>());
				case VARENUM::VT_UI8:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<unsigned int>());
				case VARENUM::VT_UINT:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NInt(object.As<unsigned int>());
				default:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
			}

		case IntrinsicKind::IntrinsicFloat:
			switch (carrier)
			{
				case VARENUM::VT_R4:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NFloat(object.As<float>());
				case VARENUM::VT_R8:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NFloat(object.As<double>());
				default:
					return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
			}
			break;

		default:
			return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
	}
}