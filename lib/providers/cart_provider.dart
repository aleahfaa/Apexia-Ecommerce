import 'package:ecommerce/services/cart_api_service.dart';
import 'package:ecommerce/models/cart_item.dart';
import 'package:flutter/foundation.dart';

enum CartStatus { initial, loading, success, error }

class CartProvider with ChangeNotifier {
  final CartApiService _apiService;
  List<CartItem> _items = [];
  CartStatus _status = CartStatus.initial;
  String? _errorMessage;
  bool _isUpdating = false;
  CartProvider(this._apiService);
  List<CartItem> get items => List.unmodifiable(_items);
  CartStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CartStatus.loading;
  bool get isUpdating => _isUpdating;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> loadCart() async {
    _setStatus(CartStatus.loading);
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _apiService.fetchCart();
      _setStatus(CartStatus.success);
      _errorMessage = null;
    } catch (e) {
      _setStatus(CartStatus.error);
      _errorMessage = e.toString();
      debugPrint('Error loading cart: $e');
    }
    notifyListeners();
  }

  Future<bool> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) return false;
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;
    final oldQuantity = _items[index].quantity;
    _items[index].quantity = newQuantity;
    notifyListeners();
    _isUpdating = true;
    notifyListeners();
    try {
      await _apiService.updateItemQuantity(itemId, newQuantity);
      _isUpdating = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _items[index].quantity = oldQuantity;
      _errorMessage = 'Failed to update quantity: $e';
      _isUpdating = false;
      notifyListeners();
      debugPrint('Error updating quantity: $e');
      return false;
    }
  }

  Future<bool> removeItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;
    final removedItem = _items.removeAt(index);
    notifyListeners();
    _isUpdating = true;
    notifyListeners();
    try {
      await _apiService.removeItem(itemId);
      _isUpdating = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _items.insert(index, removedItem);
      _errorMessage = 'Failed to remove item: $e';
      _isUpdating = false;
      notifyListeners();
      debugPrint('Error removing item: $e');
      return false;
    }
  }

  Future<bool> checkout() async {
    if (_items.isEmpty) return false;
    _isUpdating = true;
    notifyListeners();
    try {
      await _apiService.checkout(_items, totalPrice);
      _items.clear();
      _isUpdating = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Checkout failed: $e';
      _isUpdating = false;
      notifyListeners();
      debugPrint('Error during checkout: $e');
      return false;
    }
  }

  void _setStatus(CartStatus status) {
    _status = status;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
