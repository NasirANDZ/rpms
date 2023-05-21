class SignUpBody {
  String name;
  String phone;
  String email;
  String password;

  SignUpBody(
      {required this.name,
      required this.phone,
      required this.email,
      required this.password}
  );
  //---------------------- used to send data
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["f_name"] = name;
    _data["[phone"] = phone;
    _data["[email"] = email;
    _data["[password"] = password;
    return _data;
  }
}
