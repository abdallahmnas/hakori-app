import '../constants/api_constants.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'api_client.dart';

/// Product & Category API Service matching API_DOCUMENTATION.md
class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  /// Get Public Catalog Listing from API
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
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get Public Product Categories from API
  Future<List<String>> getProductCategories() async {
    try {
      final response = await _client.get(ApiConstants.productCategories);
      final data = response.data['data'];
      if (data is List && data.isNotEmpty) {
        return data.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const ['ALL'];
  }

  /// Get Product Details by ID from API
  Future<Product> getProductById(String id) async {
    final response = await _client.get(ApiConstants.productDetail(id));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final prodMap = data['product'] as Map<String, dynamic>? ?? data;
    return Product.fromJson(prodMap);
  }

  /// List Public Collections & Taxonomy from API
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
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get Collection by ID or Slug from API
  Future<Category> getCategoryById(String id) async {
    final response = await _client.get(ApiConstants.categoryDetail(id));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final catMap = data['category'] as Map<String, dynamic>? ?? data;
    return Category.fromJson(catMap);
  }
}
