import 'package:fpdart/fpdart.dart';
import 'package:seeme_test/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
