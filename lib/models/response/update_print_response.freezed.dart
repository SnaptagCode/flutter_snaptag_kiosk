// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_print_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdatePrintResponse _$UpdatePrintResponseFromJson(Map<String, dynamic> json) {
  return _UpdatePrintResponse.fromJson(json);
}

/// @nodoc
mixin _$UpdatePrintResponse {
  int get kioskEventId => throw _privateConstructorUsedError;
  int get backPhotoId => throw _privateConstructorUsedError;
  PrintStatus get status => throw _privateConstructorUsedError;
  bool get isEmbedded => throw _privateConstructorUsedError;
  int get printedPhotoCardId => throw _privateConstructorUsedError;

  /// Serializes this UpdatePrintResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdatePrintResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdatePrintResponseCopyWith<UpdatePrintResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdatePrintResponseCopyWith<$Res> {
  factory $UpdatePrintResponseCopyWith(
          UpdatePrintResponse value, $Res Function(UpdatePrintResponse) then) =
      _$UpdatePrintResponseCopyWithImpl<$Res, UpdatePrintResponse>;
  @useResult
  $Res call(
      {int kioskEventId,
      int backPhotoId,
      PrintStatus status,
      bool isEmbedded,
      int printedPhotoCardId});
}

/// @nodoc
class _$UpdatePrintResponseCopyWithImpl<$Res, $Val extends UpdatePrintResponse>
    implements $UpdatePrintResponseCopyWith<$Res> {
  _$UpdatePrintResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdatePrintResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kioskEventId = null,
    Object? backPhotoId = null,
    Object? status = null,
    Object? isEmbedded = null,
    Object? printedPhotoCardId = null,
  }) {
    return _then(_value.copyWith(
      kioskEventId: null == kioskEventId
          ? _value.kioskEventId
          : kioskEventId // ignore: cast_nullable_to_non_nullable
              as int,
      backPhotoId: null == backPhotoId
          ? _value.backPhotoId
          : backPhotoId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PrintStatus,
      isEmbedded: null == isEmbedded
          ? _value.isEmbedded
          : isEmbedded // ignore: cast_nullable_to_non_nullable
              as bool,
      printedPhotoCardId: null == printedPhotoCardId
          ? _value.printedPhotoCardId
          : printedPhotoCardId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdatePrintResponseImplCopyWith<$Res>
    implements $UpdatePrintResponseCopyWith<$Res> {
  factory _$$UpdatePrintResponseImplCopyWith(_$UpdatePrintResponseImpl value,
          $Res Function(_$UpdatePrintResponseImpl) then) =
      __$$UpdatePrintResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int kioskEventId,
      int backPhotoId,
      PrintStatus status,
      bool isEmbedded,
      int printedPhotoCardId});
}

/// @nodoc
class __$$UpdatePrintResponseImplCopyWithImpl<$Res>
    extends _$UpdatePrintResponseCopyWithImpl<$Res, _$UpdatePrintResponseImpl>
    implements _$$UpdatePrintResponseImplCopyWith<$Res> {
  __$$UpdatePrintResponseImplCopyWithImpl(_$UpdatePrintResponseImpl _value,
      $Res Function(_$UpdatePrintResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdatePrintResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kioskEventId = null,
    Object? backPhotoId = null,
    Object? status = null,
    Object? isEmbedded = null,
    Object? printedPhotoCardId = null,
  }) {
    return _then(_$UpdatePrintResponseImpl(
      kioskEventId: null == kioskEventId
          ? _value.kioskEventId
          : kioskEventId // ignore: cast_nullable_to_non_nullable
              as int,
      backPhotoId: null == backPhotoId
          ? _value.backPhotoId
          : backPhotoId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PrintStatus,
      isEmbedded: null == isEmbedded
          ? _value.isEmbedded
          : isEmbedded // ignore: cast_nullable_to_non_nullable
              as bool,
      printedPhotoCardId: null == printedPhotoCardId
          ? _value.printedPhotoCardId
          : printedPhotoCardId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdatePrintResponseImpl implements _UpdatePrintResponse {
  const _$UpdatePrintResponseImpl(
      {required this.kioskEventId,
      required this.backPhotoId,
      required this.status,
      required this.isEmbedded,
      required this.printedPhotoCardId});

  factory _$UpdatePrintResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdatePrintResponseImplFromJson(json);

  @override
  final int kioskEventId;
  @override
  final int backPhotoId;
  @override
  final PrintStatus status;
  @override
  final bool isEmbedded;
  @override
  final int printedPhotoCardId;

  @override
  String toString() {
    return 'UpdatePrintResponse(kioskEventId: $kioskEventId, backPhotoId: $backPhotoId, status: $status, isEmbedded: $isEmbedded, printedPhotoCardId: $printedPhotoCardId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdatePrintResponseImpl &&
            (identical(other.kioskEventId, kioskEventId) ||
                other.kioskEventId == kioskEventId) &&
            (identical(other.backPhotoId, backPhotoId) ||
                other.backPhotoId == backPhotoId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isEmbedded, isEmbedded) ||
                other.isEmbedded == isEmbedded) &&
            (identical(other.printedPhotoCardId, printedPhotoCardId) ||
                other.printedPhotoCardId == printedPhotoCardId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, kioskEventId, backPhotoId,
      status, isEmbedded, printedPhotoCardId);

  /// Create a copy of UpdatePrintResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdatePrintResponseImplCopyWith<_$UpdatePrintResponseImpl> get copyWith =>
      __$$UpdatePrintResponseImplCopyWithImpl<_$UpdatePrintResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdatePrintResponseImplToJson(
      this,
    );
  }
}

abstract class _UpdatePrintResponse implements UpdatePrintResponse {
  const factory _UpdatePrintResponse(
      {required final int kioskEventId,
      required final int backPhotoId,
      required final PrintStatus status,
      required final bool isEmbedded,
      required final int printedPhotoCardId}) = _$UpdatePrintResponseImpl;

  factory _UpdatePrintResponse.fromJson(Map<String, dynamic> json) =
      _$UpdatePrintResponseImpl.fromJson;

  @override
  int get kioskEventId;
  @override
  int get backPhotoId;
  @override
  PrintStatus get status;
  @override
  bool get isEmbedded;
  @override
  int get printedPhotoCardId;

  /// Create a copy of UpdatePrintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdatePrintResponseImplCopyWith<_$UpdatePrintResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
