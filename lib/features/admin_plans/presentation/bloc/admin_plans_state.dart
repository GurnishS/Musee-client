part of 'admin_plans_bloc.dart';

abstract class AdminPlansState {
  const AdminPlansState();
}

class AdminPlansInitial extends AdminPlansState {
  const AdminPlansInitial();
}

class AdminPlansLoading extends AdminPlansState {
  const AdminPlansLoading();
}

class AdminPlansFailure extends AdminPlansState {
  final String message;
  const AdminPlansFailure(this.message);
}

class AdminPlansLoaded extends AdminPlansState {
  final List<Plan> items;
  const AdminPlansLoaded(this.items);
}
