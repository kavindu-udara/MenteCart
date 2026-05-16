part of 'service_details_bloc.dart';

sealed class ServiceDetailsState {
  const ServiceDetailsState();

  const factory ServiceDetailsState.initial() = ServiceDetailsInitial;
  const factory ServiceDetailsState.loading() = ServiceDetailsLoading;
  const factory ServiceDetailsState.loaded({required ServiceModel service}) =
      ServiceDetailsLoaded;
  const factory ServiceDetailsState.empty({required String message}) =
      ServiceDetailsEmpty;
  const factory ServiceDetailsState.error({required String message}) =
      ServiceDetailsError;
}

final class ServiceDetailsInitial extends ServiceDetailsState {
  const ServiceDetailsInitial();
}

final class ServiceDetailsLoading extends ServiceDetailsState {
  const ServiceDetailsLoading();
}

final class ServiceDetailsLoaded extends ServiceDetailsState {
  final ServiceModel service;

  const ServiceDetailsLoaded({required this.service});
}

final class ServiceDetailsEmpty extends ServiceDetailsState {
  final String message;

  const ServiceDetailsEmpty({required this.message});
}

final class ServiceDetailsError extends ServiceDetailsState {
  final String message;

  const ServiceDetailsError({required this.message});
}