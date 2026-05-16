import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/cart_bloc.dart';
import '../../../bookings/presentation/bloc/bookings_bloc.dart';
import '../../../../shared/navigation/route_observer.dart';
import '../../data/repositories/cart_repository.dart';
import '../../../home/data/repositories/services_repository.dart';
import '../../../home/data/models/service_model.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../checkout/presentation/pages/payhere_webview_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with RouteAware {
  bool _isCheckingOut = false;
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

  Future<void> _showCheckoutOptions(BuildContext context, double totalAmount) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String? selected;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Select payment method - \$${totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('PayHere (Online)'),
                        value: 'payhere',
                        groupValue: selected,
                        onChanged: (value) {
                          setSheetState(() => selected = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Cash'),
                        value: 'cash',
                        groupValue: selected,
                        onChanged: (value) {
                          setSheetState(() => selected = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Pay on arrival'),
                        value: 'pay_on_arrival',
                        groupValue: selected,
                        onChanged: (value) {
                          setSheetState(() => selected = value);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: selected == null
                                ? null
                                : () async {
                                    Navigator.of(ctx).pop();
                                    await _checkout(selected!);
                                  },
                            child: const Text('Confirm & Pay'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _checkout(String method) async {
    final api = ApiClient();
    final cartBloc = context.read<CartBloc>();
    final bookingsBloc = context.read<BookingsBloc>();

    setState(() => _isCheckingOut = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await api.post('bookings/checkout', data: {'paymentMethod': method});

      // close loading
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      setState(() => _isCheckingOut = false);

      final booking = res['booking'] as Map<String, dynamic>?;

      if (method == 'payhere' && booking != null && booking['paymentInstructions'] != null) {
        final instr = booking['paymentInstructions'] as Map<String, dynamic>;
        final url = instr['url'] as String? ?? '';
        final params = (instr['params'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? <String, String>{};
        final bookingId = booking['_id'] as String? ?? booking['id'] as String? ?? '';

        if (url.isNotEmpty) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                // ignore: prefer_const_constructors
                PayHereWebViewPage(
                  paymentUrl: url,
                  params: params,
                  bookingId: bookingId,
                    onBookingSettled: () {
                      cartBloc.add(const CartRequested());
                      bookingsBloc.add(const BookingsRequested());
                    },
                ),
          ));
        }
        return;
      }

      // For cash or pay_on_arrival, show message and refresh cart
      cartBloc.add(const CartRequested());
        bookingsBloc.add(const BookingsRequested());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Checkout successful')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      setState(() => _isCheckingOut = false);
      if (e is AppException) {
        final formatted = '${e.message}${e.errorCode != null ? ' (${e.errorCode})' : ''}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(formatted)));
      } else {
        final err = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
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
                        onPressed: _isCheckingOut
                            ? null
                            : () async {
                                // Show checkout options only when there are items
                                await _showCheckoutOptions(context, cart.totalAmount);
                              },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                        child: _isCheckingOut
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Book Now'),
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
            const SizedBox(height: 12),
            // Actions: Edit slot / Delete
            Row(
              children: [
                TextButton.icon(
                    onPressed: () async {
                    final selectedDate = widget.item.selectedDate;
                    final dateStr = '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

                    ServiceModel service;
                    try {
                      service = await ServicesRepository(apiClient: ApiClient()).getServiceSlots(widget.item.serviceId, dateStr);
                    } catch (e) {
                      final errorMsg = e is AppException ? e.message : e.toString();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                      return;
                    }

                    if (service.slots.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No slots available for the selected date.')),
                      );
                      return;
                    }

                    // show bottom sheet with the cart item's selected date slots
                    String? selectedStart;
                    String? selectedEnd;
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) {
                        return SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(ctx).viewInsets.bottom,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Select a slot for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                                      style: Theme.of(ctx).textTheme.titleMedium,
                                    ),
                                  ),
                                  Flexible(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: service.slots.map((slot) {
                                        final enabled = slot.isAvailable && slot.remainingCapacity > 0;
                                        return ListTile(
                                          title: Text('${slot.startTime} - ${slot.endTime}'),
                                          subtitle: Text(enabled ? 'Available (${slot.remainingCapacity} left)' : 'Unavailable'),
                                          enabled: enabled,
                                          onTap: enabled
                                              ? () {
                                                  selectedStart = slot.startTime;
                                                  selectedEnd = slot.endTime;
                                                  Navigator.of(ctx).pop();
                                                }
                                              : null,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    if (selectedStart == null || selectedEnd == null) return;

                    try {
                      await _cartRepo.updateItemSlot(
                        itemId: widget.item.id,
                        serviceId: widget.item.serviceId,
                        selectedDate: dateStr,
                        timeSlotStart: selectedStart!,
                        timeSlotEnd: selectedEnd!,
                        quantity: quantity,
                      );
                      setState(() => quantity = quantity);
                      context.read<CartBloc>().add(const CartRequested());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot updated')));
                    } catch (e) {
                      final errorMsg = e is AppException ? e.message : e.toString();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Slot'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove item'),
                        content: const Text('Are you sure you want to remove this item from the cart?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
                        ],
                      ),
                    );
                    if (ok != true) return;

                    try {
                      await _cartRepo.removeItem(widget.item.id);
                      context.read<CartBloc>().add(const CartRequested());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed')));
                    } catch (e) {
                      final errorMsg = e is AppException ? e.message : e.toString();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
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
                            final selectedDate = widget.item.selectedDate;
                            final dateStr = '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                            try {
                              if (newQty <= 0) {
                                await _cartRepo.removeItem(widget.item.id);
                              } else {
                                await _cartRepo.updateItemQuantity(
                                  widget.item.id,
                                  serviceId: widget.item.serviceId,
                                  selectedDate: dateStr,
                                  timeSlotStart: widget.item.timeSlotStart,
                                  timeSlotEnd: widget.item.timeSlotEnd,
                                  quantity: newQty,
                                );
                                setState(() => quantity = newQty);
                              }
                              // refresh cart
                              context.read<CartBloc>().add(const CartRequested());
                            } catch (e) {
                              final errorMsg = e is AppException ? e.message : e.toString();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
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
                      final selectedDate = widget.item.selectedDate;
                      final dateStr = '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                      try {
                        // Try updating quantity on server with full payload
                        await _cartRepo.updateItemQuantity(
                          widget.item.id,
                          serviceId: widget.item.serviceId,
                          selectedDate: dateStr,
                          timeSlotStart: widget.item.timeSlotStart,
                          timeSlotEnd: widget.item.timeSlotEnd,
                          quantity: newQty,
                        );
                        setState(() => quantity = newQty);
                        context.read<CartBloc>().add(const CartRequested());
                      } catch (e) {
                        final errorMsg = e is AppException ? e.message : e.toString();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
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