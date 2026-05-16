import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/services/api_client.dart';
import '../../data/repositories/services_repository.dart';
import '../../data/models/service_model.dart';
import '../bloc/service_details_bloc.dart';
import '../../../cart/data/repositories/cart_repository.dart';
import '../bloc/home_navigation_bloc.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceDetailsBloc(
        repository: ServicesRepository(apiClient: ApiClient()),
      )..add(ServiceDetailsRequested(serviceId: serviceId)),
      child: const _ServiceDetailsView(),
    );
  }
}

class SlotSelectionResult {
  final SlotModel slot;
  final String date;

  const SlotSelectionResult({required this.slot, required this.date});
}

class _ServiceDetailsView extends StatelessWidget {
  const _ServiceDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: BlocBuilder<ServiceDetailsBloc, ServiceDetailsState>(
        builder: (context, state) {
          return switch (state) {
            ServiceDetailsInitial() || ServiceDetailsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ServiceDetailsError(:final message) => _StateMessage(
                icon: Icons.error_outline,
                title: 'Service unavailable',
                message: message,
              ),
            ServiceDetailsEmpty(:final message) => _StateMessage(
                icon: Icons.inbox_outlined,
                title: 'No service found',
                message: message,
              ),
            ServiceDetailsLoaded(:final service) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1.25,
                        child: Image.network(
                          service.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    size: 40),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      service.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.categoryId.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _InfoChip(
                          label: 'Price',
                          value: '\$${service.price.toStringAsFixed(0)}',
                        ),
                        const SizedBox(width: 12),
                        _InfoChip(
                          label: 'Duration',
                          value: '${service.duration} min',
                        ),
                        const SizedBox(width: 12),
                        _InfoChip(
                          label: 'Capacity',
                          value: service.capacityPerSlot.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          // Date picker: today .. +3 months
                          final today = DateTime.now();
                          final lastDate = DateTime(today.year, today.month + 3, today.day);
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: today,
                            firstDate: DateTime(today.year, today.month, today.day),
                            lastDate: lastDate,
                          );

                          if (picked == null) return;

                          // format YYYY-MM-DD
                          final selectedDate = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

                          final servicesRepo = ServicesRepository(apiClient: ApiClient());

                          // show loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            final serviceWithSlots = await servicesRepo.getServiceSlots(service.id, selectedDate);
                            Navigator.of(context).pop(); // remove loading

                            final availableSlots = serviceWithSlots.slots.where((s) => s.isAvailable).toList();

                            if (availableSlots.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No available slots for selected date.')),
                              );
                              return;
                            }

                            // show slots selection bottom sheet
                            final selected = await showModalBottomSheet<SlotSelectionResult?>(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) {
                                SlotModel? chosen;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Padding(
                                      padding: MediaQuery.of(context).viewInsets,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text('Select a time slot on $selectedDate', style: Theme.of(context).textTheme.titleMedium),
                                          ),
                                          ...availableSlots.map((slot) {
                                            return RadioListTile<SlotModel>(
                                              title: Text('${slot.startTime} - ${slot.endTime}'),
                                              subtitle: Text('Remaining: ${slot.remainingCapacity}'),
                                              value: slot,
                                              groupValue: chosen,
                                              onChanged: (v) => setState(() => chosen = v),
                                            );
                                          }).toList(),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: FilledButton.tonal(
                                                    onPressed: () => Navigator.of(context).pop(null),
                                                    child: const Text('Cancel'),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: FilledButton(
                                                    onPressed: chosen == null
                                                        ? null
                                                        : () => Navigator.of(context).pop(SlotSelectionResult(slot: chosen!, date: selectedDate)),
                                                    child: const Text('Confirm'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );

                            if (selected == null) return;

                            // add to cart
                            final cartRepo = CartRepository(apiClient: ApiClient());
                            // show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );

                            try {
                              await cartRepo.addItem(
                                serviceId: service.id,
                                selectedDate: selected.date,
                                timeSlotStart: selected.slot.startTime,
                                timeSlotEnd: selected.slot.endTime,
                              );
                              Navigator.of(context).pop(); // remove loading

                              // navigate to cart tab
                              try {
                                context.read<HomeNavigationBloc>().add(HomeTabSelected(1));
                              } catch (_) {}

                              Navigator.of(context).popUntil((r) => r.isFirst);
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        },
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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