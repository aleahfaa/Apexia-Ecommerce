import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ecommerce/models/cart_item.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status code: $statusCode)';
    }
    return 'ApiException: $message';
  }
}

class CartApiService {
  static const String baseUrl = 'https://api.shop.com';
  static const Duration timeoutDuration = Duration(seconds: 10);
  final String userId;
  final bool useMock;
  CartApiService({required this.userId, bool? useMock})
    : useMock = useMock ?? kIsWeb;
  Future<List<CartItem>> fetchCart() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockItems();
    }
    final uri = Uri.parse('$baseUrl/cart?userId=$userId');
    try {
      final response = await http.get(uri).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> items = decoded is Map<String, dynamic>
            ? (decoded['items'] ?? [])
            : decoded;
        return items.map((item) => CartItem.fromJson(item)).toList();
      } else {
        throw ApiException('Failed to load cart', response.statusCode);
      }
    } on TimeoutException catch (_) {
      if (kIsWeb) {
        return _mockItems();
      }
      rethrow;
    } catch (e) {
      if (kIsWeb) {
        return _mockItems();
      }
      rethrow;
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    final uri = Uri.parse('$baseUrl/cart/update');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': userId,
            'itemId': itemId,
            'quantity': quantity,
          }),
        )
        .timeout(timeoutDuration);
    if (response.statusCode != 200) {
      throw ApiException('Failed to update item', response.statusCode);
    }
  }

  Future<void> removeItem(String itemId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    final uri = Uri.parse('$baseUrl/cart/item/$itemId?userId=$userId');
    final response = await http.delete(uri).timeout(timeoutDuration);
    if (response.statusCode != 200) {
      throw ApiException('Failed to remove item', response.statusCode);
    }
  }

  Future<void> checkout(List<CartItem> items, double total) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    final uri = Uri.parse('$baseUrl/checkout');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': userId,
            'items': items.map((e) => e.toJson()).toList(),
            'total': total,
          }),
        )
        .timeout(timeoutDuration);
    if (response.statusCode != 200) {
      throw ApiException('Checkout failed', response.statusCode);
    }
  }

  List<CartItem> _mockItems() {
    return [
      CartItem(
        id: 'p1',
        name: 'Graphic T-Shirt',
        imageUrl: 'https://picsum.photos/seed/tshirt/200',
        price: 120000,
        quantity: 1,
      ),
      CartItem(
        id: 'p2',
        name: 'Running Shoes',
        imageUrl: 'https://picsum.photos/seed/shoes/200',
        price: 350000,
        quantity: 2,
      ),
      CartItem(
        id: 'p3',
        name: 'Wireless Headphones',
        imageUrl: 'https://picsum.photos/seed/headphones/200',
        price: 499000,
        quantity: 1,
      ),
    ];
  }
}
