part of 'services_bloc.dart';

sealed class ServicesState {
  const ServicesState();

  const factory ServicesState.initial() = ServicesInitial;
  const factory ServicesState.loading() = ServicesLoading;
  const factory ServicesState.loaded({required List<ServiceModel> services}) =
      ServicesLoaded;
  const factory ServicesState.empty({required String message}) = ServicesEmpty;
  const factory ServicesState.error({required String message}) = ServicesError;
}

final class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

final class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

final class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;

  const ServicesLoaded({required this.services});
}

final class ServicesEmpty extends ServicesState {
  final String message;

  const ServicesEmpty({required this.message});
}

final class ServicesError extends ServicesState {
  final String message;

  const ServicesError({required this.message});
}
