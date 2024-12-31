// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) {
  return _CreateOrderRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateOrderRequest {
  int get kioskEventId => throw _privateConstructorUsedError;
  int get kioskMachineId => throw _privateConstructorUsedError;
  String get photoAuthNumber => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String? get tradeNumber => throw _privateConstructorUsedError;
  String? get uniqueNumber => throw _privateConstructorUsedError;
  PaymentType get paymentType => throw _privateConstructorUsedError;

  /// Serializes this CreateOrderRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateOrderRequestCopyWith<CreateOrderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateOrderRequestCopyWith<$Res> {
  factory $CreateOrderRequestCopyWith(
          CreateOrderRequest value, $Res Function(CreateOrderRequest) then) =
      _$CreateOrderRequestCopyWithImpl<$Res, CreateOrderRequest>;
  @useResult
  $Res call(
      {int kioskEventId,
      int kioskMachineId,
      String photoAuthNumber,
      int amount,
      String? tradeNumber,
      String? uniqueNumber,
      PaymentType paymentType});
}

/// @nodoc
class _$CreateOrderRequestCopyWithImpl<$Res, $Val extends CreateOrderRequest>
    implements $CreateOrderRequestCopyWith<$Res> {
  _$CreateOrderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kioskEventId = null,
    Object? kioskMachineId = null,
    Object? photoAuthNumber = null,
    Object? amount = null,
    Object? tradeNumber = freezed,
    Object? uniqueNumber = freezed,
    Object? paymentType = null,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      tradeNumber: freezed == tradeNumber
          ? _value.tradeNumber
          : tradeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueNumber: freezed == uniqueNumber
          ? _value.uniqueNumber
          : uniqueNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentType: null == paymentType
          ? _value.paymentType
          : paymentType // ignore: cast_nullable_to_non_nullable
              as PaymentType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateOrderRequestImplCopyWith<$Res>
    implements $CreateOrderRequestCopyWith<$Res> {
  factory _$$CreateOrderRequestImplCopyWith(_$CreateOrderRequestImpl value,
          $Res Function(_$CreateOrderRequestImpl) then) =
      __$$CreateOrderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int kioskEventId,
      int kioskMachineId,
      String photoAuthNumber,
      int amount,
      String? tradeNumber,
      String? uniqueNumber,
      PaymentType paymentType});
}

/// @nodoc
class __$$CreateOrderRequestImplCopyWithImpl<$Res>
    extends _$CreateOrderRequestCopyWithImpl<$Res, _$CreateOrderRequestImpl>
    implements _$$CreateOrderRequestImplCopyWith<$Res> {
  __$$CreateOrderRequestImplCopyWithImpl(_$CreateOrderRequestImpl _value,
      $Res Function(_$CreateOrderRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kioskEventId = null,
    Object? kioskMachineId = null,
    Object? photoAuthNumber = null,
    Object? amount = null,
    Object? tradeNumber = freezed,
    Object? uniqueNumber = freezed,
    Object? paymentType = null,
  }) {
    return _then(_$CreateOrderRequestImpl(
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      tradeNumber: freezed == tradeNumber
          ? _value.tradeNumber
          : tradeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueNumber: freezed == uniqueNumber
          ? _value.uniqueNumber
          : uniqueNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentType: null == paymentType
          ? _value.paymentType
          : paymentType // ignore: cast_nullable_to_non_nullable
              as PaymentType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateOrderRequestImpl implements _CreateOrderRequest {
  const _$CreateOrderRequestImpl(
      {required this.kioskEventId,
      required this.kioskMachineId,
      required this.photoAuthNumber,
      required this.amount,
      this.tradeNumber,
      this.uniqueNumber,
      required this.paymentType});

  factory _$CreateOrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateOrderRequestImplFromJson(json);

  @override
  final int kioskEventId;
  @override
  final int kioskMachineId;
  @override
  final String photoAuthNumber;
  @override
  final int amount;
  @override
  final String? tradeNumber;
  @override
  final String? uniqueNumber;
  @override
  final PaymentType paymentType;

  @override
  String toString() {
    return 'CreateOrderRequest(kioskEventId: $kioskEventId, kioskMachineId: $kioskMachineId, photoAuthNumber: $photoAuthNumber, amount: $amount, tradeNumber: $tradeNumber, uniqueNumber: $uniqueNumber, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateOrderRequestImpl &&
            (identical(other.kioskEventId, kioskEventId) ||
                other.kioskEventId == kioskEventId) &&
            (identical(other.kioskMachineId, kioskMachineId) ||
                other.kioskMachineId == kioskMachineId) &&
            (identical(other.photoAuthNumber, photoAuthNumber) ||
                other.photoAuthNumber == photoAuthNumber) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.tradeNumber, tradeNumber) ||
                other.tradeNumber == tradeNumber) &&
            (identical(other.uniqueNumber, uniqueNumber) ||
                other.uniqueNumber == uniqueNumber) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, kioskEventId, kioskMachineId,
      photoAuthNumber, amount, tradeNumber, uniqueNumber, paymentType);

  /// Create a copy of CreateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateOrderRequestImplCopyWith<_$CreateOrderRequestImpl> get copyWith =>
      __$$CreateOrderRequestImplCopyWithImpl<_$CreateOrderRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateOrderRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateOrderRequest implements CreateOrderRequest {
  const factory _CreateOrderRequest(
      {required final int kioskEventId,
      required final int kioskMachineId,
      required final String photoAuthNumber,
      required final int amount,
      final String? tradeNumber,
      final String? uniqueNumber,
      required final PaymentType paymentType}) = _$CreateOrderRequestImpl;

  factory _CreateOrderRequest.fromJson(Map<String, dynamic> json) =
      _$CreateOrderRequestImpl.fromJson;

  @override
  int get kioskEventId;
  @override
  int get kioskMachineId;
  @override
  String get photoAuthNumber;
  @override
  int get amount;
  @override
  String? get tradeNumber;
  @override
  String? get uniqueNumber;
  @override
  PaymentType get paymentType;

  /// Create a copy of CreateOrderRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateOrderRequestImplCopyWith<_$CreateOrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
