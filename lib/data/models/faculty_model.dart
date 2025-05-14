import '../../domain/entities/faculty.dart';

class FacultyModel {
  final String? id;
  final String? name;

  FacultyModel({
    this.id,
    this.name,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Faculty toDomain() {
    return Faculty(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
