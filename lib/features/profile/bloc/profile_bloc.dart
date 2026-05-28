import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/users/data/repositories/user_repository_impl.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepositoryImpl _userRepository;

  ProfileBloc(this._userRepository) : super(ProfileInitial()) {
    
    // Cargar perfil usando tu método nativo real
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        // Solución a image_931c49.png: Usamos getCurrentUser()
        final user = await _userRepository.getCurrentUser(); 
        emit(ProfileLoaded(user));
      } catch (e) {
        emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // Actualizar nombre
    on<UpdateProfileNameEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final updatedUser = await _userRepository.updateUsername(event.userId, event.newUsername);
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}