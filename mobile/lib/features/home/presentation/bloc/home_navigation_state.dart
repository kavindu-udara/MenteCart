part of 'home_navigation_bloc.dart';

sealed class HomeNavigationState {
  const HomeNavigationState();

  const factory HomeNavigationState.initial() = HomeNavigationInitial;
  const factory HomeNavigationState.selected({required int index}) =
      HomeNavigationSelected;
}

final class HomeNavigationInitial extends HomeNavigationState {
  const HomeNavigationInitial();
}

final class HomeNavigationSelected extends HomeNavigationState {
  final int index;

  const HomeNavigationSelected({required this.index});
}