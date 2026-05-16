part of 'home_overview_bloc.dart';

sealed class HomeOverviewState {
  const HomeOverviewState();

  const factory HomeOverviewState.initial() = HomeOverviewInitial;
  const factory HomeOverviewState.loading() = HomeOverviewLoading;
  const factory HomeOverviewState.loaded() = HomeOverviewLoaded;
  const factory HomeOverviewState.empty({required String message}) =
      HomeOverviewEmpty;
  const factory HomeOverviewState.error({required String message}) =
      HomeOverviewError;
}

final class HomeOverviewInitial extends HomeOverviewState {
  const HomeOverviewInitial();
}

final class HomeOverviewLoading extends HomeOverviewState {
  const HomeOverviewLoading();
}

final class HomeOverviewLoaded extends HomeOverviewState {
  const HomeOverviewLoaded();
}

final class HomeOverviewEmpty extends HomeOverviewState {
  final String message;

  const HomeOverviewEmpty({required this.message});
}

final class HomeOverviewError extends HomeOverviewState {
  final String message;

  const HomeOverviewError({required this.message});
}
