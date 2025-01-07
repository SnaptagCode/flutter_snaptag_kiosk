// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'front_photo_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FrontPhotoPath {
  NominatedPhoto get photo => throw _privateConstructorUsedError;
  String get localPath => throw _privateConstructorUsedError;

  /// Create a copy of FrontPhotoPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FrontPhotoPathCopyWith<FrontPhotoPath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FrontPhotoPathCopyWith<$Res> {
  factory $FrontPhotoPathCopyWith(
          FrontPhotoPath value, $Res Function(FrontPhotoPath) then) =
      _$FrontPhotoPathCopyWithImpl<$Res, FrontPhotoPath>;
  @useResult
  $Res call({NominatedPhoto photo, String localPath});

  $NominatedPhotoCopyWith<$Res> get photo;
}

/// @nodoc
class _$FrontPhotoPathCopyWithImpl<$Res, $Val extends FrontPhotoPath>
    implements $FrontPhotoPathCopyWith<$Res> {
  _$FrontPhotoPathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FrontPhotoPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photo = null,
    Object? localPath = null,
  }) {
    return _then(_value.copyWith(
      photo: null == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as NominatedPhoto,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of FrontPhotoPath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NominatedPhotoCopyWith<$Res> get photo {
    return $NominatedPhotoCopyWith<$Res>(_value.photo, (value) {
      return _then(_value.copyWith(photo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FrontPhotoPathImplCopyWith<$Res>
    implements $FrontPhotoPathCopyWith<$Res> {
  factory _$$FrontPhotoPathImplCopyWith(_$FrontPhotoPathImpl value,
          $Res Function(_$FrontPhotoPathImpl) then) =
      __$$FrontPhotoPathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({NominatedPhoto photo, String localPath});

  @override
  $NominatedPhotoCopyWith<$Res> get photo;
}

/// @nodoc
class __$$FrontPhotoPathImplCopyWithImpl<$Res>
    extends _$FrontPhotoPathCopyWithImpl<$Res, _$FrontPhotoPathImpl>
    implements _$$FrontPhotoPathImplCopyWith<$Res> {
  __$$FrontPhotoPathImplCopyWithImpl(
      _$FrontPhotoPathImpl _value, $Res Function(_$FrontPhotoPathImpl) _then)
      : super(_value, _then);

  /// Create a copy of FrontPhotoPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photo = null,
    Object? localPath = null,
  }) {
    return _then(_$FrontPhotoPathImpl(
      photo: null == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as NominatedPhoto,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FrontPhotoPathImpl implements _FrontPhotoPath {
  const _$FrontPhotoPathImpl({required this.photo, required this.localPath});

  @override
  final NominatedPhoto photo;
  @override
  final String localPath;

  @override
  String toString() {
    return 'FrontPhotoPath(photo: $photo, localPath: $localPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrontPhotoPathImpl &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, photo, localPath);

  /// Create a copy of FrontPhotoPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrontPhotoPathImplCopyWith<_$FrontPhotoPathImpl> get copyWith =>
      __$$FrontPhotoPathImplCopyWithImpl<_$FrontPhotoPathImpl>(
          this, _$identity);
}

abstract class _FrontPhotoPath implements FrontPhotoPath {
  const factory _FrontPhotoPath(
      {required final NominatedPhoto photo,
      required final String localPath}) = _$FrontPhotoPathImpl;

  @override
  NominatedPhoto get photo;
  @override
  String get localPath;

  /// Create a copy of FrontPhotoPath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrontPhotoPathImplCopyWith<_$FrontPhotoPathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
