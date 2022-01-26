part of './thread_bloc.dart';

abstract class ThreadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThreadReloaded extends ThreadEvent {
  final String? pid;

  ThreadReloaded({this.pid});
}

class ThreadLoaded extends ThreadEvent {}