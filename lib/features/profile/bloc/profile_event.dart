abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {
}

class UpdateProfileNameEvent extends ProfileEvent {
  final int userId;
  final String newUsername;
  UpdateProfileNameEvent({required this.userId, required this.newUsername});
}