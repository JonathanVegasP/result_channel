import 'result_status.dart';

final class ResultDart {
  final ResultStatus status;
  final Object? data;

  const ResultDart({required this.status, required this.data});
}
