import 'package:clean_architecture_tdd/core/network/network_info.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([DataConnectionChecker])
void main() {
  NetworkInfoImpl? networkInfo;
  MockDataConnectionChecker? mockDataConnectionChecker;

  setUp(
    () {
      mockDataConnectionChecker = MockDataConnectionChecker();
      networkInfo = NetworkInfoImpl(mockDataConnectionChecker!);
    },
  );

  group(
    "isConnected",
    () {
      test(
        "should forward the call to DataConnectionChecker.hasConnection",
        () async {
          final tHasConnectionFuture = Future.value(true);
          when(mockDataConnectionChecker?.hasConnection)
              .thenAnswer((_) => tHasConnectionFuture);

          final result = networkInfo?.isConnected;
          verify(mockDataConnectionChecker?.hasConnection);
          expect(result, tHasConnectionFuture);
        },
      );
    },
  );
}
