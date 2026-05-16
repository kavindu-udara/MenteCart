part of 'service_details_bloc.dart';

sealed class ServiceDetailsEvent {
  const ServiceDetailsEvent();
}

final class ServiceDetailsRequested extends ServiceDetailsEvent {
  final String serviceId;

  const ServiceDetailsRequested({required this.serviceId});
}