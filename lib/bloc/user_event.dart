import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends UserEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends UserEvent {}

class RegisterRequested extends UserEvent {
  final String name;
  final String birthDate;
  final String email;
  final String password;

  const RegisterRequested(this.name, this.birthDate, this.email, this.password);

  @override
  List<Object> get props => [name, birthDate, email, password];
}