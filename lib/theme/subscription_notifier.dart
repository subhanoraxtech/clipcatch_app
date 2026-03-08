import 'package:flutter/material.dart';

class SubscriptionNotifier extends ChangeNotifier {
  bool _isPro = false;
  String _activePlan = 'None';
  DateTime? _expiryDate;

  bool get isPro => _isPro;
  String get activePlan => _activePlan;
  DateTime? get expiryDate => _expiryDate;

  void purchasePlan(String planName) {
    _isPro = true;
    _activePlan = planName;
    // Set expiry to 1 month from now for demo
    _expiryDate = DateTime.now().add(const Duration(days: 30));
    notifyListeners();
  }

  void cancelSubscription() {
    _isPro = false;
    _activePlan = 'None';
    _expiryDate = null;
    notifyListeners();
  }
}

final subscriptionNotifier = SubscriptionNotifier();
