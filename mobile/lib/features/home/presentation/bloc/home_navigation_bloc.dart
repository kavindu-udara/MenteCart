import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_navigation_event.dart';
part 'home_navigation_state.dart';

class HomeNavigationBloc extends Bloc<HomeNavigationEvent, HomeNavigationState> {
  HomeNavigationBloc() : super(const HomeNavigationState.initial()) {
    on<HomeTabSelected>(_onTabSelected);
  }

  void _onTabSelected(
    HomeTabSelected event,
    Emitter<HomeNavigationState> emit,
  ) {
    emit(HomeNavigationState.selected(index: event.index));
  }
}