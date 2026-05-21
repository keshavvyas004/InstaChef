import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0F1D25);
    const orange = Color(0xFFF79E1B);
    const cardColor = Color(0xFF1A2F3A);

    return Scaffold(
      backgroundColor: darkBlue,
      body: CustomScrollView(
        slivers: [
          // Hero Header with Gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: darkBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2A4A5A),
                      darkBlue,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [orange, orange.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: orange.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ).animate()
                       .fadeIn(duration: 400.ms)
                       .scale(begin: const Offset(0.8, 0.8), delay: 100.ms),
                      const SizedBox(height: 12),
                      Text(
                        'Privacy Policy',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: January 18, 2026',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Introduction Card
                _buildPolicyCard(
                  icon: Icons.info_outline,
                  iconColor: orange,
                  title: '1. Introduction',
                  content: 'Welcome to InstaChef. Your privacy is important to us. '
                      'This Privacy Policy explains how we collect, use, and protect your information.',
                  cardColor: cardColor,
                  index: 0,
                ),

                // Information We Collect
                _buildExpandableCard(
                  icon: Icons.folder_outlined,
                  iconColor: Colors.blue,
                  title: '2. Information We Collect',
                  items: [
                    '📧 Personal information you provide (e.g., name, email)',
                    '📊 Usage data (app interactions, preferences)',
                    '🍳 Uploaded content (recipes, images)',
                  ],
                  cardColor: cardColor,
                  index: 1,
                ),

                // How We Use Information
                _buildExpandableCard(
                  icon: Icons.settings_outlined,
                  iconColor: Colors.green,
                  title: '3. How We Use Information',
                  items: [
                    '✅ To provide and maintain our services',
                    '📈 To improve user experience',
                    '📢 To communicate updates and promotions',
                  ],
                  cardColor: cardColor,
                  index: 2,
                ),

                // Sharing Information
                _buildPolicyCard(
                  icon: Icons.share_outlined,
                  iconColor: Colors.purple,
                  title: '4. Sharing Information',
                  content: 'We do not sell your personal data. '
                      'We may share information only with trusted service providers or for legal reasons.',
                  cardColor: cardColor,
                  index: 3,
                ),

                // Data Security
                _buildPolicyCard(
                  icon: Icons.lock_outline,
                  iconColor: Colors.teal,
                  title: '5. Data Security',
                  content: 'We implement appropriate measures to protect your information, '
                      'but no method is 100% secure.',
                  cardColor: cardColor,
                  index: 4,
                ),

                // Your Rights
                _buildPolicyCard(
                  icon: Icons.person_outline,
                  iconColor: Colors.amber,
                  title: '6. Your Rights',
                  content: 'You can request access, correction, or deletion of your data at any time.',
                  cardColor: cardColor,
                  index: 5,
                ),

                // Changes to Policy
                _buildPolicyCard(
                  icon: Icons.update_outlined,
                  iconColor: Colors.cyan,
                  title: '7. Changes to This Policy',
                  content: 'We may update this Privacy Policy occasionally. '
                      'Changes will always be posted on this screen.',
                  cardColor: cardColor,
                  index: 6,
                ),

                // Contact Us
                _buildContactCard(orange, cardColor),

                const SizedBox(height: 20),

                // Footer
                Center(
                  child: Text(
                    '© 2026 InstaChef • Made with ❤️',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color cardColor,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(duration: 400.ms, delay: (100 * index).ms)
     .slideX(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildExpandableCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    required Color cardColor,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white54,
          children: items.map((item) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    ).animate()
     .fadeIn(duration: 400.ms, delay: (100 * index).ms)
     .slideX(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildContactCard(Color orange, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            orange.withOpacity(0.2),
            cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: orange.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.email_outlined, color: orange, size: 24),
                ),
                const SizedBox(width: 14),
                Text(
                  '8. Contact Us',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'For any questions about this Privacy Policy, please contact us at:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.mail, color: orange, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'instachef.hq@gmail.com',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(duration: 400.ms, delay: 700.ms)
     .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}
