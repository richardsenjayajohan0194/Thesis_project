class UserModel {
  String? name;
  String? username;
  String? password;

  UserModel({this.name, this.username, this.password});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        name: map['name'],
        username: map['username'],
        password: map['password'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'password': password
    };
  }

  void clear() {
    name = null;
    username = null;
    password = null;
    print("User  data cleared: $name");
  }

}