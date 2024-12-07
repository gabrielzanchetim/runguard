import 'package:bloc/bloc.dart';
import 'package:i_love_my_girlfriend/bloc/user_event.dart';
import 'package:i_love_my_girlfriend/bloc/user_state.dart';
import 'package:i_love_my_girlfriend/modelservices/services/auth_service.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService _authService = AuthService();

  UserBloc() : super(UserInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _authService.signIn(event.email, event.password);
      emit(UserAuthenticated());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<UserState> emit) async {
    await _authService.signOut();
    emit(UserUnauthenticated());
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _authService.signUp(event.name, event.birthDate, event.email, event.password);
      emit(UserAuthenticated());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}