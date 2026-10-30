import 'dart:convert';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
      responseDataCallback: (data) async {
        // ignore: avoid_print
        print('PERF_JSON ${jsonEncode(data)}');
      },
    );
