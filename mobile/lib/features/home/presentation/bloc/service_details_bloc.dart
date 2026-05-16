import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/service_model.dart';
import '../../data/repositories/services_repository.dart';

part 'service_details_event.dart';
part 'service_details_state.dart';

class ServiceDetailsBloc extends Bloc<ServiceDetailsEvent, ServiceDetailsState> {
  final ServicesRepository _repository;

  ServiceDetailsBloc({required ServicesRepository repository})
      : _repository = repository,
        super(const ServiceDetailsState.initial()) {
    on<ServiceDetailsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ServiceDetailsRequested event,
    Emitter<ServiceDetailsState> emit,
  ) async {
    emit(const ServiceDetailsState.loading());

    try {
      final service = await _repository.getServiceById(event.serviceId);

      if (service.id.isEmpty) {
        emit(const ServiceDetailsState.empty(
          message: 'Service not found.',
        ));
        return;
      }

      emit(ServiceDetailsState.loaded(service: service));
    } catch (e) {
      emit(ServiceDetailsState.error(message: e.toString()));
    }
  }
}