import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/cart_bloc.dart';
import '../../../../shared/navigation/route_observer.dart';
import '../../data/repositories/cart_repository.dart';
import '../../../home/data/repositories/services_repository.dart';
import '../../../home/data/models/service_model.dart';
import '../../../../shared/services/api_client.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with RouteAware {
  Future<void> _refresh() async {
    context.read<CartBloc>().add(const CartRequested());
    // small delay to allow network request to update UI
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modal = ModalRoute.of(context);
    if (modal != null) {
      routeObserver.subscribe(this, modal);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // user returned to this route -> refresh cart
    context.read<CartBloc>().add(const CartRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return switch (state) {
          CartInitial() || CartLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          CartError(:final message) => _StateMessage(
              icon: Icons.error_outline,
              title: 'Cart unavailable',
              message: message,
            ),
          CartEmpty(:final message) => _StateMessage(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: message,
            ),
          CartLoaded(:final cart) => RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Your cart is ready for review before checkout.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...cart.items.map(
                    (item) => _CartItemCard(item: item),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement booking logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking logic coming soon')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
        };
      },
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final dynamic item;

  const _CartItemCard({required this.item});

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late int quantity;
  late final Future<ServiceModel> _serviceFuture;
  final _cartRepo = CartRepository(apiClient: ApiClient());

  @override
  void initState() {
    super.initState();
    quantity = widget.item.quantity;
    _serviceFuture = ServicesRepository(apiClient: ApiClient()).getServiceById(widget.item.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormatter.format(widget.item.selectedDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FutureBuilder<ServiceModel>(
                    future: _serviceFuture,
                    builder: (context, snapshot) {
                      final serviceTitle = snapshot.hasData ? snapshot.data!.title : 'Service ID: ${widget.item.serviceId}';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.item.priceAtAdd.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Qty: $quantity',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date and time info
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.item.timeSlotStart} - ${widget.item.timeSlotEnd}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quantity control buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: quantity > 1
                        ? () async {
                            final newQty = quantity - 1;
                            try {
                              if (newQty <= 0) {
                                await _cartRepo.removeItem(widget.item.id);
                              } else {
                                await _cartRepo.updateItemQuantity(widget.item.id, newQty);
                              }
                              // refresh cart
                              context.read<CartBloc>().add(const CartRequested());
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrease'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final service = await _serviceFuture;
                      if (quantity >= service.capacityPerSlot) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reached maximum capacity per slot')));
                        return;
                      }

                      final newQty = quantity + 1;
                      try {
                        // Try updating quantity on server
                        await _cartRepo.updateItemQuantity(widget.item.id, newQty);
                        context.read<CartBloc>().add(const CartRequested());
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Increase'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}