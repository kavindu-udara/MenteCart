import 'dart:async';

import 'package:flutter/material.dart';
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

    emit(
      const HomeOverviewState.loaded(
        welcomeMessage: 'Welcome back to MenteCart',
        subtitle: 'Manage your shopping and bookings from one place.',
        highlights: [
          HomeHighlight(
            title: '3',
            label: 'Active carts',
            icon: Icons.shopping_cart_outlined,
          ),
          HomeHighlight(
            title: '12',
            label: 'Saved bookings',
            icon: Icons.book_outlined,
          ),
          HomeHighlight(
            title: '98%',
            label: 'Completion rate',
            icon: Icons.verified_outlined,
          ),
        ],
      ),
    );
  }
}