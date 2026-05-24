import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

// Estados de la máquina de autenticación
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {}
class Unauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}