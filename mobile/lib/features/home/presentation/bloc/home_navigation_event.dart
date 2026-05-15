part of 'home_navigation_bloc.dart';

sealed class HomeNavigationEvent {
  const HomeNavigationEvent();
}

final class HomeTabSelected extends HomeNavigationEvent {
  final int index;

  const HomeTabSelected(this.index);
}