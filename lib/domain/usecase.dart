abstract class UseCase<T, P> {
  Future<T> call(P params);
}

abstract class NoParamsUseCase<T> {
  Future<T> call();
}
