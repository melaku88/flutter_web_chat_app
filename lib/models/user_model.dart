class UserModel{
  String uid;
  String name;
  String email;
  String password;
  String profilePic;

  UserModel(
    this.uid,
    this.name,
    this.email,
    this.password,
    this.profilePic
  );

  Map<String, dynamic> toJson(){
    return{
      "uid": uid,
      "name": name,
      "email": email,
      "password": password,
      "profilePic": profilePic
    };
  }
}