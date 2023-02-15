enum ResultStatus { success, failure }

class Result<T> {
  final T? value;
  final List<String> errors;
  final ResultStatus status;
  final String? errorCode;

  Result(
      {this.value,
      required this.status,
      this.errors = const <String>[],
      this.errorCode});

  factory Result.success([T? value]) =>
      Result<T>(status: ResultStatus.success, value: value);

  factory Result.failure(List<String> errors, {String? code}) =>
      Result<T>(status: ResultStatus.failure, errors: errors, errorCode: code);

  bool hasErrors() => errors.isNotEmpty;

  bool get failure => status == ResultStatus.failure;

  bool get success => status == ResultStatus.success;

  String stringifyErrors() => errors.join('\n');
}