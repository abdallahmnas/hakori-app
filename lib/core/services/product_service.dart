import '../constants/api_constants.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'api_client.dart';
import 'mock_data_service.dart';

/// Product & Category API Service matching API_DOCUMENTATION.md
class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  /// Get Public Catalog Listing
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    bool? inStock,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (category != null && category.isNotEmpty && category != 'ALL') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (inStock != null) 'inStock': inStock,
      };

      final response = await _client.get(
        ApiConstants.products,
        queryParameters: query,
      );

      final data = response.data['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['products'] is List) {
        items = data['products'] as List;
      } else if (data is Map && data['items'] is List) {
        items = data['items'] as List;
      }

      if (items.isNotEmpty) {
        return items
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();
      }

      // If backend returns empty catalog, provide default showcase items
      return MockDataService.products;
    } catch (e) {
      // Graceful fallback for catalog continuity if network down
      return MockDataService.products;
    }
  }

  /// Get Public Product Categories
  Future<List<String>> getProductCategories() async {
    try {
      final response = await _client.get(ApiConstants.productCategories);
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [
      'ALL',
      'DIAMOND PAVÉ',
      'SOLID GOLD',
      'OPEN FACE',
      'FANGS & CAPS',
      'OPAL & GEMS',
    ];
  }

  /// Get Product Details by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _client.get(ApiConstants.productDetail(id));
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final prodMap = data['product'] as Map<String, dynamic>? ?? data;
      return Product.fromJson(prodMap);
    } catch (_) {
      return MockDataService.products.firstWhere(
        (p) => p.id == id,
        orElse: () => MockDataService.products[0],
      );
    }
  }

  /// List Public Collections & Taxonomy
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(ApiConstants.categories);
      final data = response.data['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['categories'] is List) {
        items = data['categories'] as List;
      }

      if (items.isNotEmpty) {
        return items
            .map((c) => Category.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      return MockDataService.categories;
    } catch (_) {
      return MockDataService.categories;
    }
  }

  /// Get Collection by ID or Slug
  Future<Category> getCategoryById(String id) async {
    try {
      final response = await _client.get(ApiConstants.categoryDetail(id));
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final catMap = data['category'] as Map<String, dynamic>? ?? data;
      return Category.fromJson(catMap);
    } catch (_) {
      return MockDataService.categories.firstWhere(
        (c) => c.id == id,
        orElse: () => MockDataService.categories[0],
      );
    }
  }
}
