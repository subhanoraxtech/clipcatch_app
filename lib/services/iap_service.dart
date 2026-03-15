import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Replace this with your actual product IDs from Play Console/App Store
  static const String kLifetimeProductId = 'clipcatch_lifetime_pro';

  ProductDetails? _lifetimeProduct;
  ProductDetails? get lifetimeProduct => _lifetimeProduct;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP: Store not available');
      return;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('IAP: Error in purchase stream: $error');
    });

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    final ProductDetailsResponse response = await _iap.queryProductDetails({kLifetimeProductId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP: Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isNotEmpty) {
      _lifetimeProduct = response.productDetails.firstWhere((p) => p.id == kLifetimeProductId);
      debugPrint('IAP: Loaded product: ${_lifetimeProduct?.title} - ${_lifetimeProduct?.price}');
    }
  }

  String get localizedPrice {
    if (_lifetimeProduct != null) {
      return _lifetimeProduct!.price;
    }
    // Return a default/fallback if store fetch fails (user's 1200 PKR as fallback)
    return '1200 PKR';
  }

  Future<void> buyProduct() async {
    if (_lifetimeProduct == null) {
      debugPrint('IAP: Cannot buy, product not loaded');
      return;
    }
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _lifetimeProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('IAP Error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Grand access to pro
        subscriptionNotifier.purchasePlan('Lifetime Pro');
        
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}

final iapService = IAPService();
