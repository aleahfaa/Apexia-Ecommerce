import 'package:ecommerce/models/cart_item.dart';
import 'package:flutter/material.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;
  final bool isUpdating;
  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
    this.isUpdating = false,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildProductInfo(context)),
            _buildRemoveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        item.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${item.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildQuantitySelector(),
        const SizedBox(height: 4),
        Text(
          'Subtotal: Rp ${item.totalPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        _buildQuantityButton(
          icon: Icons.remove,
          onPressed: item.quantity > 1
              ? () => onQuantityChanged(item.quantity - 1)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        _buildQuantityButton(
          icon: Icons.add,
          onPressed: () => onQuantityChanged(item.quantity + 1),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: isUpdating ? null : onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: onPressed == null ? Colors.grey[300]! : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(6),
          color: onPressed == null ? Colors.grey[100] : Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null ? Colors.grey[400] : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: Colors.red[400],
      onPressed: isUpdating ? null : onRemove,
      tooltip: 'Remove item',
    );
  }
}
