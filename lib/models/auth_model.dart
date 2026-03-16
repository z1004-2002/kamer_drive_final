class LoginModel {
  final String emailOrPhone;
  final String password;

  LoginModel({
    required this.emailOrPhone,
    required this.password,
  });

  // Convertit le modèle en JSON pour l'envoyer à une API (si tu n'utilises pas Firebase Auth directement)
  Map<String, dynamic> toJson() {
    return {
      'emailOrPhone': emailOrPhone,
      'password': password,
    };
  }
}

class SignupModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String birthDate; // Format "DD/MM/YYYY" récupéré du DatePicker
  final String password;

  SignupModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.password,
  });

  // Utile pour envoyer les données de création à Firebase Firestore ou une API
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'password': password, 
    };
  }
}