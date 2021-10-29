import 'package:paymongo_sdk/src/core/sdk.dart';
import 'package:paymongo_sdk/src/core/utils.dart';

/// {@template paymongo_client_sdk}
/// {@endtemplate}
class PaymongoClient<T extends Paymongo> {
  /// {@macro paymongo_client_sdk}
  const PaymongoClient(String key,
      {String url = 'api.paymongo.com', T? defaultSDK})
      : _key = key,
        _sdk = defaultSDK,
        _url = url;
  final String _key;
  final T? _sdk;
  final String _url;

  /// Retrieve the instance of [Paymongo] to access private or public APIs.
  T get instance {
    assert(_sdk != null || (T is PaymongoPublic || T is PaymongoSecret),
        PaymongoError("SDK is not either Public nor Private. "));
    final keyType = _key.split('_').first;
    if (keyType.contains(privateKey)) {
      return (PaymongoSecret()
        ..key = _key
        ..url = _url) as T;
    } else if (keyType.contains(publicKey)) {
      return (PaymongoPublic()
        ..key = _key
        ..url = _url) as T;
    } else if (_sdk != null) {
      return _sdk!;
    }
    throw PaymongoError("Key does not match with private or secret key");
  }
}

/// Throws Error
class PaymongoError extends Error {
  /// Throws Error
  PaymongoError(this.error);

  /// Error message
  final String error;
}
