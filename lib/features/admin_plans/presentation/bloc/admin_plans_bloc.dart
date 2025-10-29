import 'package:bloc/bloc.dart';
import '../../domain/entities/plan.dart';
import '../../domain/usecases/create_plan.dart';
import '../../domain/usecases/delete_plan.dart';
import '../../domain/usecases/list_plans.dart';
import '../../domain/usecases/update_plan.dart';
import 'package:musee/core/usecase/usecase.dart';

part 'admin_plans_event.dart';
part 'admin_plans_state.dart';

class AdminPlansBloc extends Bloc<AdminPlansEvent, AdminPlansState> {
  final ListPlans list;
  final CreatePlan create;
  final UpdatePlan update;
  final DeletePlan delete;

  AdminPlansBloc({
    required this.list,
    required this.create,
    required this.update,
    required this.delete,
  }) : super(const AdminPlansInitial()) {
    on<LoadPlans>(_onLoad);
    on<CreatePlanEvent>(_onCreate);
    on<UpdatePlanEvent>(_onUpdate);
    on<DeletePlanEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadPlans event, Emitter<AdminPlansState> emit) async {
    emit(const AdminPlansLoading());
    final res = await list(NoParams());
    res.fold(
      (f) => emit(AdminPlansFailure(f.message)),
      (items) => emit(AdminPlansLoaded(items)),
    );
  }

  Future<void> _onCreate(
    CreatePlanEvent event,
    Emitter<AdminPlansState> emit,
  ) async {
    emit(const AdminPlansLoading());
    final res = await create(
      CreatePlanParams(
        name: event.name,
        price: event.price,
        currency: event.currency ?? 'INR',
        billingCycle: event.billingCycle ?? 'monthly',
        features: event.features,
        maxDevices: event.maxDevices,
        isActive: event.isActive,
      ),
    );
    await res.fold((f) async => emit(AdminPlansFailure(f.message)), (_) async {
      final reload = await list(NoParams());
      reload.fold(
        (f) => emit(AdminPlansFailure(f.message)),
        (items) => emit(AdminPlansLoaded(items)),
      );
    });
  }

  Future<void> _onUpdate(
    UpdatePlanEvent event,
    Emitter<AdminPlansState> emit,
  ) async {
    emit(const AdminPlansLoading());
    final res = await update(
      UpdatePlanParams(
        id: event.id,
        name: event.name,
        price: event.price,
        currency: event.currency,
        billingCycle: event.billingCycle,
        features: event.features,
        maxDevices: event.maxDevices,
        isActive: event.isActive,
      ),
    );
    await res.fold((f) async => emit(AdminPlansFailure(f.message)), (_) async {
      final reload = await list(NoParams());
      reload.fold(
        (f) => emit(AdminPlansFailure(f.message)),
        (items) => emit(AdminPlansLoaded(items)),
      );
    });
  }

  Future<void> _onDelete(
    DeletePlanEvent event,
    Emitter<AdminPlansState> emit,
  ) async {
    emit(const AdminPlansLoading());
    final res = await delete(event.id);
    await res.fold((f) async => emit(AdminPlansFailure(f.message)), (_) async {
      final reload = await list(NoParams());
      reload.fold(
        (f) => emit(AdminPlansFailure(f.message)),
        (items) => emit(AdminPlansLoaded(items)),
      );
    });
  }
}
