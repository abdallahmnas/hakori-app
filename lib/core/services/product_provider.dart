import 'package:flutter/foundation.dart' hide Category;
import '../models/product.dart';
import '../models/category.dart';
import 'product_service.dart';

enum ProductStateStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Catalog & Categories State Provider
class ProductProvider extends ChangeNotifier {
  final ProductService _productService;

  ProductStateStatus _status = ProductStateStatus.initial;
  List<Product> _products = [];
  List<Category> _categories = [];
  List<String> _categoryFilters = ['ALL'];
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  String? _errorMessage;

  ProductProvider(this._productService);

  ProductStateStatus get status => _status;
  bool get isLoading => _status == ProductStateStatus.loading;
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  List<Category> get categories => _categories;
  List<String> get categoryFilters => _categoryFilters;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  List<Product> get _filteredProducts {
    var list = _products;
    if (_selectedCategory != 'ALL') {
      list = list.where((p) {
        final catLower = p.category.toLowerCase();
        final selLower = _selectedCategory.toLowerCase();
        return catLower == selLower || catLower.contains(selLower);
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  /// Initial load for catalog and categories
  Future<void> fetchCatalog({bool silent = false}) async {
    if (!silent) {
      _status = ProductStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetchedProducts = await _productService.getProducts(page: 0, pageSize: 50);
      final fetchedCategories = await _productService.getCategories(page: 0, pageSize: 50);
      final fetchedPills = await _productService.getProductCategories();

      _products = fetchedProducts;
      _categories = fetchedCategories;
      final Set<String> pillsSet = {'ALL'};
      for (final p in fetchedPills) {
        if (p.trim().isNotEmpty && p.toUpperCase() != 'ALL') pillsSet.add(p.trim());
      }
      for (final c in fetchedCategories) {
        if (c.name.trim().isNotEmpty && c.name.toUpperCase() != 'ALL') pillsSet.add(c.name.trim());
      }
      for (final prod in fetchedProducts) {
        if (prod.category.trim().isNotEmpty && prod.category.toUpperCase() != 'ALL') pillsSet.add(prod.category.trim());
      }
      _categoryFilters = pillsSet.toList();

      _status = ProductStateStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not load atelier pieces.';
      _status = ProductStateStatus.error;
      notifyListeners();
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Product? findProductById(String id) {
    final match = _products.where((p) => p.id == id);
    if (match.isNotEmpty) return match.first;
    return null;
  }
}
