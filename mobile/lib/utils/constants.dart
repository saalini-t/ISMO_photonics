import 'dart:io';
import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000/api';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';
  } else {
    return 'http://localhost:3000/api';
  }
}

const String kAuthTokenKey = 'auth_token';
const String kUserDataKey = 'user_data';
