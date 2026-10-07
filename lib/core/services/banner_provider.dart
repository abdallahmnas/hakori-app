import 'package:flutter/foundation.dart';
import '../models/promo_banner.dart';
import 'banner_service.dart';
import 'storage_service.dart';

/// Provider for managing promotional hero banners with offline storage cache
class BannerProvider extends ChangeNotifier {
  final BannerService _bannerService;
  final StorageService? _storageService;

  List<PromoBanner> _banners = [];
  bool _isLoading = false;
  String? _errorMessage;

  BannerProvider(this._bannerService, [this._storageService]) {
    _restoreFromCache();
  }

  List<PromoBanner> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _restoreFromCache() {
    final storage = _storageService;
    if (storage != null) {
      final cached = storage.getCachedBanners();
      if (cached.isNotEmpty) {
        _banners = cached;
      }
    }
  }

  /// Fetch hero banners from API and update local storage cache
  Future<void> fetchBanners({bool silent = false}) async {
    if (_banners.isEmpty && !silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _bannerService.getHeroBanners(
        placement: 'hero',
        all: true,
      );

      if (fetched.isNotEmpty) {
        _banners = fetched;
        _storageService?.saveCachedBanners(fetched);
      }
      _errorMessage = null;
    } catch (e) {
      if (_banners.isEmpty) {
        _errorMessage = 'Could not load banners';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
