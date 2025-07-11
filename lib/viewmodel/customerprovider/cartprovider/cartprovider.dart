import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';

class Cartprovider with ChangeNotifier {
  final List<Fetchserviceprovidermodel> _cartitems = [];
  List<Fetchserviceprovidermodel> get cartitems => _cartitems;
  void addtocart(Fetchserviceprovidermodel item) async {
    if (!_cartitems.any((e) => e.serviceId == item.serviceId)) {
      _cartitems.add(item);
      notifyListeners();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(item.serviceId)
          .set(item.tomap());
    }
  }

  Future<void> fetchcart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection("cart")
            .get();
    final List<Fetchserviceprovidermodel> loaditems =
        snapshot.docs
            .map((doc) => Fetchserviceprovidermodel.fromMap(doc.data()))
            .toList();
    _cartitems.clear();
    _cartitems.addAll(loaditems);
    notifyListeners();
  }

  void removefromcart(String serviceId) async {
    _cartitems.removeWhere((items) => items.serviceId == serviceId);
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(serviceId)
          .delete();
    }
  }

  Future<void> clearcart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final cartref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart');
      final snapshot = await cartref.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      _cartitems.clear();
      notifyListeners();
    }
  }
}
