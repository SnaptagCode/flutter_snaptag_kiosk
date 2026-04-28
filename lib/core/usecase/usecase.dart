import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class UseCase<T, P> {
  Future<AsyncValue<T>> call(P params);
}

abstract class NoParamsUseCase<T> {
  Future<AsyncValue<T>> call();
}
