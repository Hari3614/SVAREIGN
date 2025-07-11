import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // radius of the Earth in Km
  final dlat = _degtorad(lat2 - lat1);
  final dlon = _degtorad(lon2 - lon1);
  final a =
      sin(dlat / 2) * sin(dlat / 2) +
      cos(_degtorad(lat1) * cos(_degtorad(lat2))) *
          sin(dlon / 2) *
          sin(dlon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _degtorad(double deg) => deg * pi / 180;
