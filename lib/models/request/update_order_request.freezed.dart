// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdateOrderRequest _$UpdateOrderRequestFromJson(Map<String, dynamic> json) {
  return _UpdateOrderRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateOrderRequest {
  int get kioskEventId => throw _privateConstructorUsedError;
  int get kioskMachineId => throw _privateConstructorUsedError;
  String get photoAuthNumber => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get purchaseAuthNumber => throw _privateConstructorUsedError;
  String get authSeqNumber => throw _privateConstructorUsedError;
  String get approvalNumber => throw _privateConstructorUsedError;
  String? get tradeNumber => throw _privateConstructorUsedError;
  String? get uniqueNumber => throw _privateConstructorUsedError;
  String get detail => throw _privateConstructorUsedError;

  /// Serializes this UpdateOrderRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateOrderRequestCopyWith<UpdateOrderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateOrderRequestCopyWith<$Res> {
  factory $UpdateOrderRequestCopyWith(
          UpdateOrderRequest value, $Res Function(UpdateOrderRequest) then) =
      _$UpdateOrderRequestCopyWithImpl<$Res, UpdateOrderRequest>;
  @useResult
  $Res call(
      {int kioskEventId,
      int kioskMachineId,
      String photoAuthNumber,
      OrderStatus status,
      int amount,
      String purchaseAuthNumber,
      String authSeqNumber,
      String approvalNumber,
      String? tradeNumber,
      String? uniqueNumber,
      String detail});
}

/// @nodoc
class _$UpdateOrderRequestCopyWithImpl<$Res, $Val extends UpdateOrderRequest>
    implements $UpdateOrderRequestCopyWith<$Res> {
  _$UpdateOrderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kioskEventId = null,
    Object? kioskMachineId = null,
    Object? photoAuthNumber = null,
    Object? status = null,
    Object? amount = null,
    Object? purchaseAuthNumber = null,
    Object? authSeqNumber = null,
    Object? approvalNumber = null,
    Object? tradeNumber = freezed,
    Object? uniqueNumber = freezed,
    Object? detail = null,
  }) {
    return _then(_value.copyWith(
      kioskEventId: null == kioskEventId
          ? _value.kioskEventId
          : kioskEventId // ignore: cast_nullable_to_non_nullable
              as int,
      kioskMachineId: null == kioskMachineId
          ? _value.kioskMachineId
          : kioskMachineId // ignore: cast_nullable_to_non_nullable
              as int,
      photoAuthNumber: null == photoAuthNumber
          ? _value.photoAuthNumber
          : photoAuthNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      purchaseAuthNumber: null == purchaseAuthNumber
          ? _value.purchaseAuthNumber
          : purchaseAuthNumber // ignore: cast_nullable_to_non_nullable
              as String,
      authSeqNumber: null == authSeqNumber
          ? _value.authSeqNumber
          : authSeqNumber // ignore: cast_nullable_to_non_nullable
              as String,
      approvalNumber: null == approvalNumber
          ? _value.approvalNumber
          : approvalNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tradeNumber: freezed == tradeNumber
          ? _value.tradeNumber
          : tradeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueNumber: freezed == uniqueNumber
          ? _value.uniqueNumber
          : uniqueNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateOrderRequestImplCopyWith<$Res>
    implements $UpdateOrderRequestCopyWith<$Res> {
  factory _$$UpdateOrderRequestImplCopyWith(_$UpdateOrderRequestImpl value,
          $Res Function(_$UpdateOrderRequestImpl) then) =
      __$$UpdateOrderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int kioskEventId,
      int kioskMachineId,
      String photoAuthNumber,
      OrderStatus status,
      int amount,
      String purchaseAuthNumber,
      String authSeqNumber,
      String approvalNumber,
      String? tradeNumber,
      String? uniqueNumber,
      String detail});
}

/// @nodoc
class __$$UpdateOrderRequestImplCopyWithImpl<$Res>
    extends _$UpdateOrderRequestCopyWithImpl<$Res, _$UpdateOrderRequestImpl>
    implements _$$UpdateOrderRequestImplCopyWith<$Res> {
  __$$UpdateOrderRequestImplCopyWithImpl(_$UpdateOrderRequestImpl _value,
      $Res Function(_$UpdateOrderRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpdateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kioskEventId = null,
    Object? kioskMachineId = null,
    Object? photoAuthNumber = null,
    Object? status = null,
    Object? amount = null,
    Object? purchaseAuthNumber = null,
    Object? authSeqNumber = null,
    Object? approvalNumber = null,
    Object? tradeNumber = freezed,
    Object? uniqueNumber = freezed,
    Object? detail = null,
  }) {
    return _then(_$UpdateOrderRequestImpl(
      kioskEventId: null == kioskEventId
          ? _value.kioskEventId
          : kioskEventId // ignore: cast_nullable_to_non_nullable
              as int,
      kioskMachineId: null == kioskMachineId
          ? _value.kioskMachineId
          : kioskMachineId // ignore: cast_nullable_to_non_nullable
              as int,
      photoAuthNumber: null == photoAuthNumber
          ? _value.photoAuthNumber
          : photoAuthNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      purchaseAuthNumber: null == purchaseAuthNumber
          ? _value.purchaseAuthNumber
          : purchaseAuthNumber // ignore: cast_nullable_to_non_nullable
              as String,
      authSeqNumber: null == authSeqNumber
          ? _value.authSeqNumber
          : authSeqNumber // ignore: cast_nullable_to_non_nullable
              as String,
      approvalNumber: null == approvalNumber
          ? _value.approvalNumber
          : approvalNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tradeNumber: freezed == tradeNumber
          ? _value.tradeNumber
          : tradeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueNumber: freezed == uniqueNumber
          ? _value.uniqueNumber
          : uniqueNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateOrderRequestImpl implements _UpdateOrderRequest {
  const _$UpdateOrderRequestImpl(
      {required this.kioskEventId,
      required this.kioskMachineId,
      required this.photoAuthNumber,
      required this.status,
      required this.amount,
      required this.purchaseAuthNumber,
      required this.authSeqNumber,
      required this.approvalNumber,
      this.tradeNumber,
      this.uniqueNumber,
      required this.detail});

  factory _$UpdateOrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateOrderRequestImplFromJson(json);

  @override
  final int kioskEventId;
  @override
  final int kioskMachineId;
  @override
  final String photoAuthNumber;
  @override
  final OrderStatus status;
  @override
  final int amount;
  @override
  final String purchaseAuthNumber;
  @override
  final String authSeqNumber;
  @override
  final String approvalNumber;
  @override
  final String? tradeNumber;
  @override
  final String? uniqueNumber;
  @override
  final String detail;

  @override
  String toString() {
    return 'UpdateOrderRequest(kioskEventId: $kioskEventId, kioskMachineId: $kioskMachineId, photoAuthNumber: $photoAuthNumber, status: $status, amount: $amount, purchaseAuthNumber: $purchaseAuthNumber, authSeqNumber: $authSeqNumber, approvalNumber: $approvalNumber, tradeNumber: $tradeNumber, uniqueNumber: $uniqueNumber, detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateOrderRequestImpl &&
            (identical(other.kioskEventId, kioskEventId) ||
                other.kioskEventId == kioskEventId) &&
            (identical(other.kioskMachineId, kioskMachineId) ||
                other.kioskMachineId == kioskMachineId) &&
            (identical(other.photoAuthNumber, photoAuthNumber) ||
                other.photoAuthNumber == photoAuthNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.purchaseAuthNumber, purchaseAuthNumber) ||
                other.purchaseAuthNumber == purchaseAuthNumber) &&
            (identical(other.authSeqNumber, authSeqNumber) ||
                other.authSeqNumber == authSeqNumber) &&
            (identical(other.approvalNumber, approvalNumber) ||
                other.approvalNumber == approvalNumber) &&
            (identical(other.tradeNumber, tradeNumber) ||
                other.tradeNumber == tradeNumber) &&
            (identical(other.uniqueNumber, uniqueNumber) ||
                other.uniqueNumber == uniqueNumber) &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      kioskEventId,
      kioskMachineId,
      photoAuthNumber,
      status,
      amount,
      purchaseAuthNumber,
      authSeqNumber,
      approvalNumber,
      tradeNumber,
      uniqueNumber,
      detail);

  /// Create a copy of UpdateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateOrderRequestImplCopyWith<_$UpdateOrderRequestImpl> get copyWith =>
      __$$UpdateOrderRequestImplCopyWithImpl<_$UpdateOrderRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateOrderRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateOrderRequest implements UpdateOrderRequest {
  const factory _UpdateOrderRequest(
      {required final int kioskEventId,
      required final int kioskMachineId,
      required final String photoAuthNumber,
      required final OrderStatus status,
      required final int amount,
      required final String purchaseAuthNumber,
      required final String authSeqNumber,
      required final String approvalNumber,
      final String? tradeNumber,
      final String? uniqueNumber,
      required final String detail}) = _$UpdateOrderRequestImpl;

  factory _UpdateOrderRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateOrderRequestImpl.fromJson;

  @override
  int get kioskEventId;
  @override
  int get kioskMachineId;
  @override
  String get photoAuthNumber;
  @override
  OrderStatus get status;
  @override
  int get amount;
  @override
  String get purchaseAuthNumber;
  @override
  String get authSeqNumber;
  @override
  String get approvalNumber;
  @override
  String? get tradeNumber;
  @override
  String? get uniqueNumber;
  @override
  String get detail;

  /// Create a copy of UpdateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateOrderRequestImplCopyWith<_$UpdateOrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
