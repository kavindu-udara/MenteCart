part of 'services_bloc.dart';

sealed class ServicesEvent {
  const ServicesEvent();
}

final class ServicesRequested extends ServicesEvent {
  const ServicesRequested();
}
