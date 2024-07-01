import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:zulip/api/core.dart';
import 'package:zulip/model/store.dart';

import '../example_data.dart' as eg;

sealed class _PreparedResponse {
  final Duration delay;

  _PreparedResponse({this.delay = Duration.zero});
}

class _PreparedException extends _PreparedResponse {
  final Object exception;

  _PreparedException({super.delay, required this.exception});
}

class _PreparedSuccess extends _PreparedResponse {
  final int httpStatus;
  final List<int> bytes;

  _PreparedSuccess({super.delay, required this.httpStatus, required this.bytes});
}

/// An [http.Client] that accepts and replays canned responses, for testing.
class FakeHttpClient extends http.BaseClient {

  http.BaseRequest? lastRequest;

  http.BaseRequest? takeLastRequest() {
    final result = lastRequest;
    lastRequest = null;
    return result;
  }

  _PreparedResponse? _nextResponse;

  // Please add more features to this mocking API as needed.  For example:
  //  * preparing more than one request, and logging more than one request

  /// Prepare the response for the next request.
  ///
  /// If `exception` is null, the next request will produce an [http.Response]
  /// with the given `httpStatus`, defaulting to 200.  The body of the response
  /// will be `body` if non-null, or `jsonEncode(json)` if `json` is non-null,
  /// or else ''.  The `body` and `json` parameters must not both be non-null.
  ///
  /// If `exception` is non-null, then `httpStatus`, `body`, and `json` must
  /// all be null, and the next request will throw the given exception.
  void prepare({
    Object? exception,
    int? httpStatus,
    Map<String, dynamic>? json,
    String? body,
    Duration delay = Duration.zero,
  }) {
    assert(_nextResponse == null,
      'FakeApiConnection.prepare was called while already expecting a request');
    if (exception != null) {
      assert(httpStatus == null && json == null && body == null);
      _nextResponse = _PreparedException(exception: exception, delay: delay);
    } else {
      assert((json == null) || (body == null));
      final String resolvedBody = switch ((body, json)) {
        (var body?, _) => body,
        (_, var json?) => jsonEncode(json),
        _              => '',
      };
      _nextResponse = _PreparedSuccess(
        httpStatus: httpStatus ?? 200,
        bytes: utf8.encode(resolvedBody),
        delay: delay,
      );
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    lastRequest = request;

    if (_nextResponse == null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'An API request was attempted in a test when no response was prepared.'),
        ErrorDescription(
          'Each API request in a test context must be preceded by a corresponding '
          'call to [FakeApiConnection.prepare].'),
      ]);
    }
    final response = _nextResponse!;
    _nextResponse = null;

    final http.StreamedResponse Function() computation;
    switch (response) {
      case _PreparedException(:var exception):
        computation = () => throw exception;
      case _PreparedSuccess(:var bytes, :var httpStatus):
        final byteStream = http.ByteStream.fromBytes(bytes);
        computation = () => http.StreamedResponse(
          byteStream, httpStatus, request: request);
    }
    return Future.delayed(response.delay, computation);
  }
}

/// An [ApiConnection] that accepts and replays canned responses, for testing.
///
/// This is the [ApiConnection] subclass used by [TestGlobalStore].
/// In tests that use a store (including most of our widget tests),
/// one typically uses [PerAccountStore.connection] to get
/// the relevant instance of this class.
///
/// Tests that don't use a store (in particular our API-binding tests)
/// typically use [FakeApiConnection.with_] to obtain an instance of this class.
class FakeApiConnection extends ApiConnection {
  /// Construct an [ApiConnection] that accepts and replays canned responses, for testing.
  ///
  /// Typically a test does not call this constructor directly.  Instead:
  ///  * when a test store is being used, invoke [PerAccountStore.connection]
  ///    to get the [FakeApiConnection] used by the relevant store;
  ///  * otherwise, call [FakeApiConnection.with_] to make a fresh
  ///    [FakeApiConnection] and cleanly close it.
  ///
  /// If `zulipFeatureLevel` is omitted, it defaults to [eg.futureZulipFeatureLevel],
  /// which causes route bindings to behave as they would for the
  /// latest Zulip server versions.
  /// To set `zulipFeatureLevel` to null, pass null explicitly.
  FakeApiConnection({
    Uri? realmUrl,
    int? zulipFeatureLevel = eg.futureZulipFeatureLevel,
    String? email,
    String? apiKey,
  }) : this._(
         realmUrl: realmUrl ?? eg.realmUrl,
         zulipFeatureLevel: zulipFeatureLevel,
         email: email,
         apiKey: apiKey,
         client: FakeHttpClient(),
       );

  FakeApiConnection.fromAccount(Account account)
    : this(
        realmUrl: account.realmUrl,
        zulipFeatureLevel: account.zulipFeatureLevel,
        email: account.email,
        apiKey: account.apiKey);

  FakeApiConnection._({
    required super.realmUrl,
    required super.zulipFeatureLevel,
    super.email,
    super.apiKey,
    required this.client,
  }) : super(client: client);

  final FakeHttpClient client;

  /// Run the given callback on a fresh [FakeApiConnection], then close it,
  /// using try/finally.
  ///
  /// If `zulipFeatureLevel` is omitted, it defaults to [eg.futureZulipFeatureLevel],
  /// which causes route bindings to behave as they would for the
  /// latest Zulip server versions.
  /// To set `zulipFeatureLevel` to null, pass null explicitly.
  static Future<T> with_<T>(
    Future<T> Function(FakeApiConnection connection) fn, {
    Uri? realmUrl,
    int? zulipFeatureLevel = eg.futureZulipFeatureLevel,
    Account? account,
  }) async {
    assert((account == null)
      || (realmUrl == null && zulipFeatureLevel == eg.futureZulipFeatureLevel));
    final connection = (account != null)
      ? FakeApiConnection.fromAccount(account)
      : FakeApiConnection(realmUrl: realmUrl, zulipFeatureLevel: zulipFeatureLevel);
    try {
      return await fn(connection);
    } finally {
      connection.close();
    }
  }

  /// True just if [close] has never been called on this connection.
  // In principle this could live on [ApiConnection]... but [http.Client]
  // offers no way to tell if [http.Client.close] has been called,
  // so we follow that library's lead on this point of API design.
  bool get isOpen => _isOpen;
  bool _isOpen = true;

  @override
  void close() {
    _isOpen = false;
    super.close();
  }

  http.BaseRequest? get lastRequest => client.lastRequest;

  http.BaseRequest? takeLastRequest() => client.takeLastRequest();

  /// Prepare the response for the next request.
  ///
  /// If `exception` is null, the next request will produce an [http.Response]
  /// with the given `httpStatus`, defaulting to 200.  The body of the response
  /// will be `body` if non-null, or `jsonEncode(json)` if `json` is non-null,
  /// or else ''.  The `body` and `json` parameters must not both be non-null.
  ///
  /// If `exception` is non-null, then `httpStatus`, `body`, and `json` must
  /// all be null, and the next request will throw the given exception.
  ///
  /// In either case, the next request will complete a duration of `delay`
  /// after being started.
  void prepare({
    Object? exception,
    int? httpStatus,
    Map<String, dynamic>? json,
    String? body,
    Duration delay = Duration.zero,
  }) {
    client.prepare(
      exception: exception,
      httpStatus: httpStatus, json: json, body: body,
      delay: delay,
    );
  }
}
