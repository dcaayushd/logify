class OAuthUser {
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;

  const OAuthUser(
      {required this.firstName,
      required this.lastName,
      required this.email,
      this.photoUrl,
      this.phoneNumber});
}