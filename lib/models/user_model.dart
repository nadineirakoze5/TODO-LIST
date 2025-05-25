class UserModel {
  final int? localId; // For SQLite (auto-incremented int ID)
  final String? id; // For Firestore document ID
  final String name;
  final String email;
  final String password;

  UserModel({
    this.localId,
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  /// 🔹 Convert to Firestore format (omit localId)
  Map<String, dynamic> toFirestoreMap() => {
    'name': name,
    'email': email,
    'password': password,
  };

  /// 🔹 Convert to SQLite format
  Map<String, dynamic> toSqliteMap() => {
    'id': localId,
    'name': name,
    'email': email,
    'password': password,
  };

  /// 🔹 Create from Firestore map (requires doc.id passed)
  factory UserModel.fromFirestore(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  /// 🔹 Create from SQLite map
  factory UserModel.fromSqlite(Map<String, dynamic> map) {
    return UserModel(
      localId: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  /// Optional: Password checker
  bool checkPassword(String inputPassword) => inputPassword == password;

  /// Optional: Copy method
  UserModel copyWith({
    int? localId,
    String? id,
    String? name,
    String? email,
    String? password,
  }) {
    return UserModel(
      localId: localId ?? this.localId,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
