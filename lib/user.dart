// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';

part 'user.g.dart';


List<User> userFromJson(String str) => List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? firstName;
  @HiveField(3)
  final String? lastName;
  @HiveField(4)
  final String? email;
  @HiveField(5)
  final String? gender;
  @HiveField(6)
  final String? ipAddress;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.ipAddress,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    String? ipAddress,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        gender: json["gender"],
        ipAddress: json["ip_address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "gender": gender,
        "ip_address": ipAddress,
      };

 

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, ipAddress: $ipAddress)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.gender == gender &&
        other.ipAddress == ipAddress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        gender.hashCode ^
        ipAddress.hashCode;
  }
}
