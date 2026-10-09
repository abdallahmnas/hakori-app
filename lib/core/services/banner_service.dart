import '../constants/api_constants.dart';
import '../models/promo_banner.dart';
import 'api_client.dart';

/// Banner Service to fetch promotional hero banners from API
class BannerService {
  final ApiClient _client;

  BannerService(this._client);

  /// Fetch promotional banners matching curl:
  /// GET /api/banners?placement=hero&all=true
  Future<List<PromoBanner>> getHeroBanners({
    String placement = 'hero',
    bool all = true,
  }) async {
    final response = await _client.get(
      ApiConstants.banners,
      queryParameters: {
        'placement': placement,
        'all': all,
      },
    );

    final raw = response.data;
    List list = [];
    if (raw is List) {
      list = raw;
    } else if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        list = data;
      } else if (data is Map && data['banners'] is List) {
        list = data['banners'] as List;
      } else if (raw['banners'] is List) {
        list = raw['banners'] as List;
      }
    }

    return list
        .map((item) => PromoBanner.fromJson(item as Map<String, dynamic>))
        .where((b) => b.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}
