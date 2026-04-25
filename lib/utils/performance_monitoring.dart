import 'package:firebase_performance/firebase_performance.dart';

// Export Trace class for convenience
export 'package:firebase_performance/firebase_performance.dart'
    show Trace, HttpMetric, HttpMethod;

class PerformanceMonitoring {
  static FirebasePerformance? _performance;

  static void initialize() {
    _performance = FirebasePerformance.instance;
    _performance!.setPerformanceCollectionEnabled(true);
  }

  static Future<Trace> startTrace(String name) async {
    final trace = _performance?.newTrace(name);
    await trace?.start();
    return trace!;
  }

  static Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }

  static Future<HttpMetric> startHttpMetric(
    String url,
    HttpMethod httpMethod,
  ) async {
    final metric = _performance?.newHttpMetric(url, httpMethod);
    await metric?.start();
    return metric!;
  }

  static Future<void> stopHttpMetric(HttpMetric metric) async {
    await metric.stop();
  }

  // Predefined traces for common operations
  static Future<Trace> startAuthProviderTrace() async {
    return startTrace('auth_provider_operations');
  }

  static Future<Trace> startFirestoreOperationsTrace() async {
    return startTrace('firestore_operations');
  }

  static Future<Trace> startImageLoadingTrace() async {
    return startTrace('image_loading');
  }

  static Future<Trace> startApiCallTrace(String endpoint) async {
    return startTrace('api_call_$endpoint');
  }
}
