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
  List<String> _categoryFilters = [
    'ALL',
    'DIAMOND PAVÉ',
    'SOLID GOLD',
    'OPEN FACE',
    'FANGS & CAPS',
    'OPAL & GEMS',
  ];
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
        if (_selectedCategory == 'DIAMOND PAVÉ') return p.category.toLowerCase().contains('diamond');
        if (_selectedCategory == 'SOLID GOLD') return p.category.toLowerCase().contains('solid') || p.category.toLowerCase().contains('gold');
        if (_selectedCategory == 'OPEN FACE') return p.category.toLowerCase().contains('open');
        if (_selectedCategory == 'FANGS & CAPS') return p.category.toLowerCase().contains('fang') || p.category.toLowerCase().contains('cap');
        if (_selectedCategory == 'OPAL & GEMS') return p.category.toLowerCase().contains('opal') || p.category.toLowerCase().contains('gem') || p.category.toLowerCase().contains('emerald');
        return p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
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
      final fetchedProducts = await _productService.getProducts(pageSize: 50);
      final fetchedCategories = await _productService.getCategories();
      final fetchedPills = await _productService.getProductCategories();

      _products = fetchedProducts;
      _categories = fetchedCategories;
      if (fetchedPills.isNotEmpty) {
        final pills = ['ALL', ...fetchedPills.where((c) => c != 'ALL')];
        _categoryFilters = pills;
      }

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
