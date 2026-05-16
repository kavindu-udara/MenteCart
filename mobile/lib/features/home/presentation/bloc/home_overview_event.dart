part of 'home_overview_bloc.dart';

sealed class HomeOverviewEvent {
  const HomeOverviewEvent();
}

final class HomeOverviewRequested extends HomeOverviewEvent {
  const HomeOverviewRequested();
}