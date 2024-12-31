// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nominated_photo_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NominatedPhotoList _$NominatedPhotoListFromJson(Map<String, dynamic> json) {
  return _NominatedPhotoList.fromJson(json);
}

/// @nodoc
mixin _$NominatedPhotoList {
  List<NominatedPhoto> get list => throw _privateConstructorUsedError;

  /// Serializes this NominatedPhotoList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NominatedPhotoList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NominatedPhotoListCopyWith<NominatedPhotoList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NominatedPhotoListCopyWith<$Res> {
  factory $NominatedPhotoListCopyWith(
          NominatedPhotoList value, $Res Function(NominatedPhotoList) then) =
      _$NominatedPhotoListCopyWithImpl<$Res, NominatedPhotoList>;
  @useResult
  $Res call({List<NominatedPhoto> list});
}

/// @nodoc
class _$NominatedPhotoListCopyWithImpl<$Res, $Val extends NominatedPhotoList>
    implements $NominatedPhotoListCopyWith<$Res> {
  _$NominatedPhotoListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NominatedPhotoList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? list = null,
  }) {
    return _then(_value.copyWith(
      list: null == list
          ? _value.list
          : list // ignore: cast_nullable_to_non_nullable
              as List<NominatedPhoto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NominatedPhotoListImplCopyWith<$Res>
    implements $NominatedPhotoListCopyWith<$Res> {
  factory _$$NominatedPhotoListImplCopyWith(_$NominatedPhotoListImpl value,
          $Res Function(_$NominatedPhotoListImpl) then) =
      __$$NominatedPhotoListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<NominatedPhoto> list});
}

/// @nodoc
class __$$NominatedPhotoListImplCopyWithImpl<$Res>
    extends _$NominatedPhotoListCopyWithImpl<$Res, _$NominatedPhotoListImpl>
    implements _$$NominatedPhotoListImplCopyWith<$Res> {
  __$$NominatedPhotoListImplCopyWithImpl(_$NominatedPhotoListImpl _value,
      $Res Function(_$NominatedPhotoListImpl) _then)
      : super(_value, _then);

  /// Create a copy of NominatedPhotoList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? list = null,
  }) {
    return _then(_$NominatedPhotoListImpl(
      list: null == list
          ? _value._list
          : list // ignore: cast_nullable_to_non_nullable
              as List<NominatedPhoto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NominatedPhotoListImpl implements _NominatedPhotoList {
  const _$NominatedPhotoListImpl({required final List<NominatedPhoto> list})
      : _list = list;

  factory _$NominatedPhotoListImpl.fromJson(Map<String, dynamic> json) =>
      _$$NominatedPhotoListImplFromJson(json);

  final List<NominatedPhoto> _list;
  @override
  List<NominatedPhoto> get list {
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_list);
  }

  @override
  String toString() {
    return 'NominatedPhotoList(list: $list)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NominatedPhotoListImpl &&
            const DeepCollectionEquality().equals(other._list, _list));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_list));

  /// Create a copy of NominatedPhotoList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NominatedPhotoListImplCopyWith<_$NominatedPhotoListImpl> get copyWith =>
      __$$NominatedPhotoListImplCopyWithImpl<_$NominatedPhotoListImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NominatedPhotoListImplToJson(
      this,
    );
  }
}

abstract class _NominatedPhotoList implements NominatedPhotoList {
  const factory _NominatedPhotoList(
      {required final List<NominatedPhoto> list}) = _$NominatedPhotoListImpl;

  factory _NominatedPhotoList.fromJson(Map<String, dynamic> json) =
      _$NominatedPhotoListImpl.fromJson;

  @override
  List<NominatedPhoto> get list;

  /// Create a copy of NominatedPhotoList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NominatedPhotoListImplCopyWith<_$NominatedPhotoListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
