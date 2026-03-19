import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kamer_drive_final/core/constants/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // On écoute le ProfileProvider au lieu de l'AuthProvider
    final currentUser = context.watch<ProfileProvider>().currentUser;

    bool isProfileIncomplete =
        currentUser != null &&
        (currentUser.address.isEmpty || currentUser.phone.isEmpty);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            left: -size.width * 0.3,
            bottom: size.height * 0.4,
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
            right: -size.width * 0.4,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(
                color: kSecondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kPrimaryColor, dPrimaryColor],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: const SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              "Mon Profil",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: lPrimaryColor,
                          backgroundImage:
                              (currentUser != null &&
                                  currentUser.avatarUrl.isNotEmpty)
                              ? NetworkImage(currentUser.avatarUrl)
                              : null,
                          child:
                              (currentUser == null ||
                                  currentUser.avatarUrl.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: kPrimaryColor,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "${currentUser?.firstName ?? 'Utilisateur'} ${currentUser?.lastName ?? ''}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                currentUser?.email ?? 'Chargement...',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (currentUser?.phone == null || currentUser!.phone.isEmpty)
                      ? 'Téléphone non renseigné'
                      : currentUser.phone,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (isProfileIncomplete) ...[
                        _buildProfileAlertCard(context),
                        const SizedBox(height: 20),
                      ],

                      _buildMenuBlock([
                        _buildMenuItem(
                          Icons.person_outline,
                          "Informations personnelles",
                          () {
                            context.push('/edit_profile');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          Icons.badge_outlined,
                          "Mes documents (Identité/Permis)",
                          () {
                            context.push('/documents');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          Icons.payment_outlined,
                          "Moyens de paiement",
                          () {
                            _showComingSoonDialog(context);
                          },
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _buildMenuBlock([
                        _buildMenuItem(
                          Icons.help_outline,
                          "Aide & Support",
                          () {
                            context.push('/help');
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          Icons.privacy_tip_outlined,
                          "Politique de confidentialité",
                          () {
                            context.push('/privacy_policy');
                          },
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _buildMenuBlock([
                        _buildMenuItem(
                          Icons.logout,
                          "Se déconnecter",
                          () => _showLogoutDialog(context),
                          isDestructive: true,
                        ),
                      ]),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAlertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profil incomplet",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ajoutez vos informations pour pouvoir utiliser toutes les fonctionnalités.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => context.push('/documents'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            child: const Text(
              "Compléter",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBlock(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    Color itemColor = isDestructive ? Colors.red : Colors.black87;
    Color iconBgColor = isDestructive
        ? Colors.red.withOpacity(0.1)
        : lPrimaryColor;
    Color iconColor = isDestructive ? Colors.red : kPrimaryColor;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: itemColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildMenuDivider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.shade100,
    indent: 70,
    endIndent: 20,
  );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Déconnexion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Provider.of<ProfileProvider>(
                context,
                listen: false,
              ).clearProfile(); // Nettoie le profil
              await Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout(); // Gère le log out Firebase
              if (context.mounted) context.go('/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Se déconnecter",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  } // --- ALERTE BIENTÔT DISPONIBLE ---

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch,
                color: Colors.blue.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                "Bientôt disponible",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          "La gestion sécurisée des moyens de paiement (Mobile Money, Cartes Bancaires) est en cours de développement.\n\nRestez à l'écoute pour la prochaine mise à jour !",
          style: TextStyle(height: 1.5, fontSize: 14, color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "J'ai compris",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
