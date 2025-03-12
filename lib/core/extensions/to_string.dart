import 'dart:ffi';

extension PointerToString<T extends NativeType> on Pointer<T> {
  /// 포인터의 값을 문자열로 변환하여 반환하는 함수
  String toFormattedString(int length) {
    if (this == nullptr) return "nullptr";

    if (T == Uint8) {
      return (this as Pointer<Uint8>).asTypedList(length).join(", ");
    } else if (T == Uint32) {
      return (this as Pointer<Uint32>).asTypedList(length).join(", ");
    } else if (T == Int32) {
      return (this as Pointer<Int32>).asTypedList(length).join(", ");
    } else {
      return "Unsupported Type";
    }
  }
}
