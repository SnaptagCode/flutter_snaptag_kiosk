import 'package:freezed_annotation/freezed_annotation.dart';

part 'paging_entity.freezed.dart';
part 'paging_entity.g.dart';

@freezed
class PagingEntity with _$PagingEntity {
  factory PagingEntity({
    required int totalCount,
    required int pageSize,
    required int currentPage,
    required bool canNext,
  }) = _PagingEntity;

  factory PagingEntity.fromJson(Map<String, dynamic> json) => _$PagingEntityFromJson(json);
}
