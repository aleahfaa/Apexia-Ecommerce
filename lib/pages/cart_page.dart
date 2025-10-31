import 'package:ecommerce/widgets/cartItem_widget.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return _buildBody(cart);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Shopping Cart'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<CartProvider>().loadCart(),
          tooltip: 'Refresh cart',
        ),
      ],
    );
  }

  Widget _buildBody(CartProvider cart) {
    if (cart.status == CartStatus.error) {
      return _buildErrorView(cart);
    }
    if (cart.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cart.isEmpty) {
      return _buildEmptyCart();
    }
    return Column(
      children: [
        if (cart.errorMessage != null) _buildErrorBanner(cart),
        Expanded(child: _buildCartList(cart)),
        _buildCheckoutSection(cart),
      ],
    );
  }

  Widget _buildErrorView(CartProvider cart) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load cart',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              cart.errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => cart.loadCart(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(CartProvider cart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cart.errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => cart.clearError(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartProvider cart) {
    return ListView.builder(
      itemCount: cart.items.length,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return CartItemWidget(
          item: item,
          isUpdating: cart.isUpdating,
          onQuantityChanged: (newQuantity) {
            cart.updateQuantity(item.id, newQuantity);
          },
          onRemove: () => _confirmRemoveItem(cart, item.id, item.name),
        );
      },
    );
  }

  Widget _buildCheckoutSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: cart.isEmpty || cart.isUpdating
                    ? null
                    : () => _handleCheckout(cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: cart.isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveItem(
    CartProvider cart,
    String itemId,
    String itemName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "$itemName" from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final success = await cart.removeItem(itemId);
      if (!success && mounted) {
        _showSnackBar('Failed to remove item. Please try again.');
      }
    }
  }

  Future<void> _handleCheckout(CartProvider cart) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your order...'),
          ],
        ),
      ),
    );
    final success = await cart.checkout();
    if (!mounted) return;
    Navigator.pop(context);
    if (success) {
      _showSuccessDialog();
    } else {
      _showSnackBar(cart.errorMessage ?? 'Checkout failed. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        content: const Text('Your order has been placed successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
      ),
    );
  }
}
