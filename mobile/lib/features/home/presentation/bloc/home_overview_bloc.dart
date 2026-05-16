import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_overview_event.dart';
part 'home_overview_state.dart';

class HomeOverviewBloc extends Bloc<HomeOverviewEvent, HomeOverviewState> {
  HomeOverviewBloc() : super(const HomeOverviewState.initial()) {
    on<HomeOverviewRequested>(_onRequested);
  }

  Future<void> _onRequested(
    HomeOverviewRequested event,
    Emitter<HomeOverviewState> emit,
  ) async {
    emit(const HomeOverviewState.loading());

    await Future<void>.delayed(const Duration(milliseconds: 250));

    emit(const HomeOverviewState.loaded());
  }
}