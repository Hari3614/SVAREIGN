import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:svareign/utils/calculatedistance/calculatedistance.dart';

class Availablityservice with ChangeNotifier {
  List<Fetchserviceprovidermodel> _availableprovider = [];
  bool _isloading = false;
  List<Fetchserviceprovidermodel> get availableProvider => _availableprovider;
  bool get isloading => _isloading;
  Future<void> fetchavailableProvider({
    required double userLat,
    required double userlng,
    double radiusinKm = 20,
  }) async {
    _isloading = true;
    notifyListeners();

    List<Fetchserviceprovidermodel> provider = [];

    try {
      final servicesnapshot =
          await FirebaseFirestore.instance.collection('services').get();

      debugPrint("Fetched service docs: ${servicesnapshot.docs.length}");

      if (servicesnapshot.docs.isNotEmpty) {
        for (var doc in servicesnapshot.docs) {
          final servicedata = doc.data();
          final lat = servicedata['location']?['latitude'];
          final long = servicedata['location']?['longitude'];

          if (lat == null || long == null) continue;

          final distance = calculateDistance(userLat, userlng, lat, long);
          debugPrint("Service ID: ${doc.id}, Distance: $distance km");

          if (distance > radiusinKm) continue;

          final profilesnapshot =
              await doc.reference
                  .collection('profile')
                  .where('available', isEqualTo: true)
                  .get();

          for (var profiledoc in profilesnapshot.docs) {
            final profiledata = profiledoc.data();

            final mergedata = {
              ...profiledata,
              'location': servicedata['location'],
              'serviceId': doc.id,
            };

            provider.add(Fetchserviceprovidermodel.fromMap(mergedata));
          }
        }
      }
    } catch (e, stack) {
      debugPrint(" Error in fetchavailableProvider: $e");
      debugPrint("Stack trace: $stack");
    }

    _availableprovider = provider;
    _isloading = false;
    notifyListeners();
  }

  Future<void> fetchproviderbycategoryandplace({
    required double userLat,
    required double userlng,
    required String category,
    double radiusinKm = 20,
  }) async {
    try {
      _isloading = true;
      notifyListeners();

      final servicesnapshot =
          await FirebaseFirestore.instance.collection('services').get();

      List<Fetchserviceprovidermodel> providers = [];

      for (var serviceDoc in servicesnapshot.docs) {
        final servicedata = serviceDoc.data();
        final lat = servicedata['location']?['latitude'];
        final long = servicedata['location']?['longitude'];

        if (lat == null || long == null) continue;

        final distance = calculateDistance(userLat, userlng, lat, long);
        if (distance > radiusinKm) continue;

        final profilesnapshot =
            await serviceDoc.reference
                .collection('profile')
                .where('categories', arrayContains: category)
                .get();

        for (var profiledoc in profilesnapshot.docs) {
          final profiledata = profiledoc.data();

          final mergedata = {
            ...profiledata,
            'location': servicedata['location'],
            'serviceId': serviceDoc.id,
          };

          providers.add(Fetchserviceprovidermodel.fromMap(mergedata));
        }
      }

      _availableprovider = providers;
    } catch (e) {
      debugPrint(" Error Fetching providers by category and place: $e");
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
