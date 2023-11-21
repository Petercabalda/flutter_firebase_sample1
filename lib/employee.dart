class Employee {
  final String id;
  final String name;
  final String email;
  final String image;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'image': image,
      };

  static Employee fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Default Name';
    final email = json['email'] as String? ?? 'Default Email';
    final id = json['id'] as String? ?? 'Default Id';
    final image = json['image'] as String? ?? 'Default image';

    return Employee(
      id: id,
      name: name,
      email: email,
      image: image,
    );
  }
}
