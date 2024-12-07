class AppUser {
  final String username;
  final String email;
  final String gender;
  final bool agreeToTerms;
  final int altura;
  final String? reference;

  AppUser({
    required this.username,
    required this.email,
    required this.gender,
    required this.agreeToTerms,
    required this.altura,
    this.reference, 
  });

  factory AppUser.fromJson(String id, Map<String, dynamic>? json, {String? reference}) {
    if (json == null) {
      throw ArgumentError("Invalid JSON: JSON is null"); 
    }

    if (!json.containsKey('username') || json['username'] is! String) {
      throw ArgumentError("Invalid JSON: Missing or invalid 'username' field");
    }
    if (!json.containsKey('email') || json['email'] is! String) {
      throw ArgumentError("Invalid JSON: Missing or invalid 'email' field");
    }
    if (!json.containsKey('gender') || json['gender'] is! String) {
      throw ArgumentError("Invalid JSON: Missing or invalid 'gender' field");
    }
    if (!json.containsKey('agreeToTerms') || json['agreeToTerms'] is! bool) {
      throw ArgumentError("Invalid JSON: Missing or invalid 'agreeToTerms' field");
    }
    if (!json.containsKey('altura') || json['altura'] is! int) {
      throw ArgumentError("Invalid JSON: Missing or invalid 'altura' field");
    }

    return AppUser(
      username: json['username'],
      email: json['email'],
      gender: json['gender'],
      agreeToTerms: json['agreeToTerms'],
      altura: json['altura'],
      reference: reference,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'gender': gender,
        'agreeToTerms': agreeToTerms,
        'altura': altura,
        if (reference != null) 'reference': reference, 
      };
}
