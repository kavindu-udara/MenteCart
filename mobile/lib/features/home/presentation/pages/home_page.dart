import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mente_cart/shared/services/api_client.dart';

import '../../../bookings/presentation/bloc/bookings_bloc.dart';
import '../../../bookings/data/repositories/bookings_repository.dart';
import '../../../bookings/presentation/pages/bookings_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/data/repositories/cart_repository.dart';
import '../../data/repositories/services_repository.dart';
import '../bloc/home_navigation_bloc.dart';
import '../bloc/home_overview_bloc.dart';
import '../bloc/services_bloc.dart';
import 'home_overview_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeNavigationBloc(),
        ),
        BlocProvider(
          create: (_) => HomeOverviewBloc()..add(const HomeOverviewRequested()),
        ),
        BlocProvider(
          create: (_) => CartBloc(
            cartRepository: CartRepository(apiClient: apiClient),
          )..add(const CartRequested()),
        ),
        BlocProvider(
          create: (_) => BookingsBloc(
            repository: BookingsRepository(apiClient: apiClient),
          )..add(const BookingsRequested()),
        ),
        BlocProvider(
          create: (_) => ServicesBloc(
            repository: ServicesRepository(apiClient: apiClient),
          )..add(const ServicesRequested()),
        ),
      ],
      child: BlocListener<HomeNavigationBloc, HomeNavigationState>(
        listener: (context, state) {
          final index = switch (state) {
            HomeNavigationSelected(:final index) => index,
            _ => 0,
          };

          if (index == 1) {
            // When Cart tab is selected, refresh cart from backend
            context.read<CartBloc>().add(const CartRequested());
          }
        },
        child: BlocBuilder<HomeNavigationBloc, HomeNavigationState>(
          builder: (context, state) {
            final currentIndex = switch (state) {
              HomeNavigationSelected(:final index) => index,
              _ => 0,
            };

          return Scaffold(
            appBar: AppBar(
              title: Text(_titleForIndex(currentIndex)),
              backgroundColor: Theme.of(context).colorScheme.surface,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
            body: IndexedStack(
              index: currentIndex,
              children: const [
                HomeOverviewPage(),
                CartPage(),
                BookingsPage(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                context.read<HomeNavigationBloc>().add(HomeTabSelected(index));
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: 'Bookings',
                ),
              ],
            ),
          );
        },
      ),
    ),
    );
  }

  String _titleForIndex(int index) {
    return switch (index) {
      1 => 'Cart',
      2 => 'Bookings',
      _ => 'Home',
    };
  }
}
