part of 'admin_users_bloc.dart';

sealed class AdminUsersState {
  const AdminUsersState();
}

final class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

final class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

final class AdminUsersFailure extends AdminUsersState {
  final String message;
  const AdminUsersFailure(this.message);
}

final class AdminUsersPageLoaded extends AdminUsersState {
  final List<User> items;
  final int total;
  final int page;
  final int limit;
  final String? search;

  const AdminUsersPageLoaded({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.search,
  });

  AdminUsersPageLoaded copyWith({
    List<User>? items,
    int? total,
    int? page,
    int? limit,
    String? search,
  }) {
    return AdminUsersPageLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
    );
  }
}
