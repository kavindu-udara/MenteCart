import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/services/api_client.dart';
import '../../data/repositories/services_repository.dart';
import '../bloc/service_details_bloc.dart';

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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking flow is coming soon.'),
                            ),
                          );
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