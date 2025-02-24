import 'package:hive_flutter/hive_flutter.dart';

part '../generated_files/auth_model.g.dart';

@HiveType(typeId: 1)
class AuthModel {
  AuthModel(this.userName, this.password);

  @HiveField(0)
  final String userName;

  @HiveField(1)
  final String password;
}
