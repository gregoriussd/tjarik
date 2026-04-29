class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? profileUrl;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.profileUrl,
  });

factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'],
      profileUrl: data['profile_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profile_url': profileUrl,
    };
  }
}