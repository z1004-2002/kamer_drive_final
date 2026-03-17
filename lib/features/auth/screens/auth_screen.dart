import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import 'package:kamer_drive_final/core/utils/snackbar_utils.dart';
import 'package:kamer_drive_final/features/auth/providers/auth_provider.dart';
import 'package:kamer_drive_final/models/auth_model.dart';
import 'package:kamer_drive_final/shared/widgets/button.dart';
import 'package:kamer_drive_final/shared/widgets/logo.dart';
import 'package:kamer_drive_final/shared/widgets/name.dart';
import 'package:kamer_drive_final/shared/widgets/textfield.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // On commence par la connexion par défaut

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // Fond épuré
      body: SizedBox(
        width: double.infinity,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- CERCLES DÉCORATIFS ---
            Positioned(
              top: -size.width * 0.2,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: const BoxDecoration(
                  color: kSecondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.2,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: const BoxDecoration(
                  color: kSecondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // // --- LOGO EN FOND ---
            // Positioned(
            //   bottom: size.height * 0.5,
            //   child: Column(
            //     children: [
            //       Opacity(opacity: 0.15, child: Name(size: size.width * 0.16)),
            //     ],
            //   ),
            // ),

            // --- ANIMATION ENTRE CONNEXION ET INSCRIPTION ---
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isLogin
                    ? LoginForm(
                        key: const ValueKey("Login"),
                        onSwitch: toggleView,
                      )
                    : SignupForm(
                        key: const ValueKey("Signup"),
                        onSwitch: toggleView,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 1. FORMULAIRE DE CONNEXION
// =========================================================================
class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginForm({Key? key, required this.onSwitch}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

 Future<void> _submitLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      SnackbarUtils.showWarning(context, "Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loginData = LoginModel(
        emailOrPhone: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // On récupère le résultat de la fonction login (isFirstConnection)
      bool needsProfiling = await Provider.of<AuthProvider>(context, listen: false).login(loginData);

      if (mounted) {
        SnackbarUtils.showSuccess(context, "Connexion réussie !");
        
        // REDIRECTION INTELLIGENTE
        if (needsProfiling) {
          context.go('/profiling'); // Il n'a pas fini son profilage
        } else {
          context.go('/home'); // Profilage déjà fait, direction l'accueil
        }
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KamerDriveLogo(
              size: 70, // Très grand
              showText: false,
            ),
            // const Name(size: 35), // Logo officiel
            const SizedBox(height: 10),
            const Text(
              "Heureux de vous revoir !",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            ModernTextField(
              hintText: "Email",
              icon: Icons.person_outline,
              controller: _emailController,
            ),
            const SizedBox(height: 20),

            ModernTextField(
              hintText: "Mot de passe",
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    SnackbarUtils.showWarning(context, "Bientôt disponible !"),
                child: const Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),

            ModernButton(
              text: "SE CONNECTER",
              isLoading: _isLoading,
              press: _submitLogin,
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Pas encore de compte ? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: widget.onSwitch,
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            //!const OrDivider(),
            //!const SocialLoginRow(),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 2. FORMULAIRE D'INSCRIPTION
// =========================================================================
class SignupForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignupForm({Key? key, required this.onSwitch}) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

Future<void> _submitSignup() async {
    // ... tes vérifications actuelles (nom, email, mot de passe) ...

    setState(() => _isLoading = true);

    try {
      final signupData = SignupModel(
        firstName: _prenomController.text.trim(),
        lastName: _nomController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _dateController.text.trim(),
        password: _passController.text.trim(),
      );

      await Provider.of<AuthProvider>(context, listen: false).signup(signupData);

      if (mounted) {
        SnackbarUtils.showSuccess(context, "Compte créé avec succès !");
        
        // Pour une inscription, c'est TOUJOURS la première connexion
        context.go('/profiling'); 
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const Name(size: 30),
            const SizedBox(height: 10),
            const Text(
              "Rejoignez l'aventure KamerDrive",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ModernTextField(
                    hintText: "Nom",
                    icon: Icons.person_outline,
                    controller: _nomController,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ModernTextField(
                    hintText: "Prénom",
                    icon: Icons.person_outline,
                    controller: _prenomController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            ModernTextField(
              hintText: "Email",
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 15),

            ModernTextField(
              hintText: "Téléphone",
              icon: Icons.phone_outlined,
              inputType: TextInputType.phone,
              controller: _phoneController,
            ),
            const SizedBox(height: 15),

            // Date Picker intégré dans le nouveau style
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: kPrimaryColor,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (pickedDate != null) {
                  setState(
                    () => _dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
                  );
                }
              },
              child: AbsorbPointer(
                // Empêche le clavier de s'ouvrir
                child: ModernTextField(
                  hintText: "Date de naissance",
                  icon: Icons.calendar_today_outlined,
                  controller: _dateController,
                ),
              ),
            ),
            const SizedBox(height: 15),

            const Divider(color: Colors.grey, thickness: 0.3, height: 30),

            ModernTextField(
              hintText: "Mot de passe",
              icon: Icons.lock_outline,
              controller: _passController,
              isPassword: true,
            ),
            const SizedBox(height: 15),
            ModernTextField(
              hintText: "Confirmer mot de passe",
              icon: Icons.lock_outline,
              controller: _confirmPassController,
              isPassword: true,
            ),
            const SizedBox(height: 30),

            ModernButton(
              text: "S'INSCRIRE",
              isLoading: _isLoading,
              press: _submitSignup,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Déjà un compte ? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: widget.onSwitch,
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
