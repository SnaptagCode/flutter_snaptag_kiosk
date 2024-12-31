// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nominated_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NominatedPhoto _$NominatedPhotoFromJson(Map<String, dynamic> json) {
  return _NominatedPhoto.fromJson(json);
}

/// @nodoc
mixin _$NominatedPhoto {
  int get id => throw _privateConstructorUsedError;
  int get embeddingProductId => throw _privateConstructorUsedError;
  String get embeddedUrl => throw _privateConstructorUsedError;

  /// Serializes this NominatedPhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NominatedPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NominatedPhotoCopyWith<NominatedPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NominatedPhotoCopyWith<$Res> {
  factory $NominatedPhotoCopyWith(
          NominatedPhoto value, $Res Function(NominatedPhoto) then) =
      _$NominatedPhotoCopyWithImpl<$Res, NominatedPhoto>;
  @useResult
  $Res call({int id, int embeddingProductId, String embeddedUrl});
}

/// @nodoc
class _$NominatedPhotoCopyWithImpl<$Res, $Val extends NominatedPhoto>
    implements $NominatedPhotoCopyWith<$Res> {
  _$NominatedPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NominatedPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? embeddingProductId = null,
    Object? embeddedUrl = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      embeddingProductId: null == embeddingProductId
          ? _value.embeddingProductId
          : embeddingProductId // ignore: cast_nullable_to_non_nullable
              as int,
      embeddedUrl: null == embeddedUrl
          ? _value.embeddedUrl
          : embeddedUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NominatedPhotoImplCopyWith<$Res>
    implements $NominatedPhotoCopyWith<$Res> {
  factory _$$NominatedPhotoImplCopyWith(_$NominatedPhotoImpl value,
          $Res Function(_$NominatedPhotoImpl) then) =
      __$$NominatedPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int embeddingProductId, String embeddedUrl});
}

/// @nodoc
class __$$NominatedPhotoImplCopyWithImpl<$Res>
    extends _$NominatedPhotoCopyWithImpl<$Res, _$NominatedPhotoImpl>
    implements _$$NominatedPhotoImplCopyWith<$Res> {
  __$$NominatedPhotoImplCopyWithImpl(
      _$NominatedPhotoImpl _value, $Res Function(_$NominatedPhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of NominatedPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? embeddingProductId = null,
    Object? embeddedUrl = null,
  }) {
    return _then(_$NominatedPhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      embeddingProductId: null == embeddingProductId
          ? _value.embeddingProductId
          : embeddingProductId // ignore: cast_nullable_to_non_nullable
              as int,
      embeddedUrl: null == embeddedUrl
          ? _value.embeddedUrl
          : embeddedUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NominatedPhotoImpl implements _NominatedPhoto {
  const _$NominatedPhotoImpl(
      {required this.id,
      required this.embeddingProductId,
      required this.embeddedUrl});

  factory _$NominatedPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NominatedPhotoImplFromJson(json);

  @override
  final int id;
  @override
  final int embeddingProductId;
  @override
  final String embeddedUrl;

  @override
  String toString() {
    return 'NominatedPhoto(id: $id, embeddingProductId: $embeddingProductId, embeddedUrl: $embeddedUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NominatedPhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.embeddingProductId, embeddingProductId) ||
                other.embeddingProductId == embeddingProductId) &&
            (identical(other.embeddedUrl, embeddedUrl) ||
                other.embeddedUrl == embeddedUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, embeddingProductId, embeddedUrl);

  /// Create a copy of NominatedPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NominatedPhotoImplCopyWith<_$NominatedPhotoImpl> get copyWith =>
      __$$NominatedPhotoImplCopyWithImpl<_$NominatedPhotoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NominatedPhotoImplToJson(
      this,
    );
  }
}

abstract class _NominatedPhoto implements NominatedPhoto {
  const factory _NominatedPhoto(
      {required final int id,
      required final int embeddingProductId,
      required final String embeddedUrl}) = _$NominatedPhotoImpl;

  factory _NominatedPhoto.fromJson(Map<String, dynamic> json) =
      _$NominatedPhotoImpl.fromJson;

  @override
  int get id;
  @override
  int get embeddingProductId;
  @override
  String get embeddedUrl;

  /// Create a copy of NominatedPhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NominatedPhotoImplCopyWith<_$NominatedPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
