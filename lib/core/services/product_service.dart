import '../constants/api_constants.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'api_client.dart';

/// Product & Category API Service matching API_DOCUMENTATION.md
class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  /// Get Public Catalog Listing from API (0-based pagination)
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    bool? inStock,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'currentPage': page,
        'page': page,
        'itemsPerPage': pageSize,
        'pageSize': pageSize,
        if (category != null && category.isNotEmpty && category != 'ALL') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (inStock != null) 'inStock': inStock,
      };

      final response = await _client.get(
        ApiConstants.products,
        queryParameters: query,
      );

      final respData = response.data;
      List items = [];
      if (respData is List) {
        items = respData;
      } else if (respData is Map) {
        final data = respData['data'];
        if (data is List) {
          items = data;
        } else if (data is Map && data['products'] is List) {
          items = data['products'] as List;
        } else if (data is Map && data['items'] is List) {
          items = data['items'] as List;
        } else if (respData['products'] is List) {
          items = respData['products'] as List;
        }
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
      final respData = response.data;
      dynamic data;
      if (respData is Map && respData['data'] != null) {
        data = respData['data'];
      } else if (respData is List) {
        data = respData;
      }
      if (data is List && data.isNotEmpty) {
        return data.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const ['ALL'];
  }

  /// Get Product Details by ID from API
  Future<Product> getProductById(String id) async {
    final response = await _client.get(ApiConstants.productDetail(id));
    final respData = response.data;
    Map<String, dynamic> prodMap = {};
    if (respData is Map) {
      final data = respData['data'];
      if (data is Map<String, dynamic>) {
        prodMap = data['product'] as Map<String, dynamic>? ?? data;
      } else {
        prodMap = Map<String, dynamic>.from(respData);
      }
    }
    return Product.fromJson(prodMap);
  }

  /// List Public Collections & Taxonomy from API (0-based pagination)
  Future<List<Category>> getCategories({
    int page = 0,
    int pageSize = 20,
    String? subCategoryType,
  }) async {
    try {
      final query = <String, dynamic>{
        'currentPage': page,
        'page': page,
        'itemsPerPage': pageSize,
        'pageSize': pageSize,
        if (subCategoryType != null && subCategoryType.isNotEmpty)
          'subCategoryType': subCategoryType,
      };

      final response = await _client.get(
        ApiConstants.categories,
        queryParameters: query,
      );

      final respData = response.data;
      List items = [];
      if (respData is List) {
        items = respData;
      } else if (respData is Map) {
        final data = respData['data'];
        if (data is List) {
          items = data;
        } else if (data is Map && data['categories'] is List) {
          items = data['categories'] as List;
        } else if (data is Map && data['items'] is List) {
          items = data['items'] as List;
        } else if (respData['categories'] is List) {
          items = respData['categories'] as List;
        }
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
