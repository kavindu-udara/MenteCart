import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/service_model.dart';
import '../../data/repositories/services_repository.dart';

part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServicesRepository _repository;

  ServicesBloc({required ServicesRepository repository})
      : _repository = repository,
        super(const ServicesState.initial()) {
    on<ServicesRequested>(_onServicesRequested);
  }

  Future<void> _onServicesRequested(
    ServicesRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(const ServicesState.loading());

    try {
      final response = await _repository.getServices();
      
      if (response.services.isEmpty) {
        emit(
          const ServicesState.empty(message: 'No services available'),
        );
      } else {
        emit(
          ServicesState.loaded(services: response.services),
        );
      }
    } catch (e) {
      emit(
        ServicesState.error(message: e.toString()),
      );
    }
  }
}
