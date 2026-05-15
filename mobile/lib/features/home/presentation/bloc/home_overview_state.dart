part of 'home_overview_bloc.dart';

sealed class HomeOverviewState {
  const HomeOverviewState();

  const factory HomeOverviewState.initial() = HomeOverviewInitial;
  const factory HomeOverviewState.loading() = HomeOverviewLoading;
  const factory HomeOverviewState.loaded({
    required String welcomeMessage,
    required String subtitle,
    required List<HomeHighlight> highlights,
  }) = HomeOverviewLoaded;
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
  final String welcomeMessage;
  final String subtitle;
  final List<HomeHighlight> highlights;

  const HomeOverviewLoaded({
    required this.welcomeMessage,
    required this.subtitle,
    required this.highlights,
  });
}

final class HomeOverviewEmpty extends HomeOverviewState {
  final String message;

  const HomeOverviewEmpty({required this.message});
}

final class HomeOverviewError extends HomeOverviewState {
  final String message;

  const HomeOverviewError({required this.message});
}

final class HomeHighlight {
  final String title;
  final String label;
  final IconData icon;

  const HomeHighlight({
    required this.title,
    required this.label,
    required this.icon,
  });
}