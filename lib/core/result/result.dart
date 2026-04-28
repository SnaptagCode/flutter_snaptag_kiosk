sealed class Result<T, E> {
  const Result();

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  bool get isSuccess => this is Success;
  bool get isFailure => this is Failure;
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      success(value);
}

final class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      failure(error);
}
