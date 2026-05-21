import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Colour palette (matches dashboard) ──────────────────────────────────────
const Color _bgColor      = Color.fromRGBO(15, 29, 37, 1);
const Color _cardColor    = Color.fromRGBO(24, 46, 61, 1);
const Color _primaryColor = Color.fromRGBO(247, 158, 27, 1);
const Color _dangerColor  = Color(0xFFEF5350);
const Color _successColor = Color(0xFF66BB6A);
const Color _infoColor    = Color(0xFF42A5F5);
const Color _textMuted    = Color(0xFF8FA8BC);

// The Firestore app-id used in posts collection
const String _APP_ID = '1:250338435801:android:ddd8de8871e9db841c54c8';

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  bool _isAdmin   = false;
  bool _isLoading = true;
  final _me = FirebaseAuth.instance.currentUser!;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  late final AnimationController _fadeCtr;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtr = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtr, curve: Curves.easeIn);
    _checkAdmin();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fadeCtr.dispose();
    super.dispose();
  }

  // ── Admin check ──────────────────────────────────────────────────────────────

  Future<void> _checkAdmin() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(_me.uid).get();
      setState(() {
        _isAdmin   = doc.exists && (doc.data()?['isAdmin'] == true);
        _isLoading = false;
      });
      if (_isAdmin) _fadeCtr.forward();
    } catch (e) {
      setState(() { _isAdmin = false; _isLoading = false; });
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _deleteUser(String uid) async {
    final ok = await _confirmDialog(
      icon: Icons.delete_forever_rounded,
      iconColor: _dangerColor,
      title: 'Delete User',
      message: 'This permanently removes the user & all their data. Cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: _dangerColor,
    );
    if (ok != true) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Dialog(
          backgroundColor: _cardColor,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: _primaryColor),
              SizedBox(width: 16),
              Text('Deleting user…', style: TextStyle(color: Colors.white)),
            ]),
          ),
        ),
      );
    }

    try {
      // Delete user document directly from Firestore (no backend needed)
      final db = FirebaseFirestore.instance;

      // 1. Remove user doc
      await db.collection('users').doc(uid).delete();

      // 2. Also remove any saved posts references for this user
      //    (posts where savedBy contains this uid)
      final postsSnap = await db
          .collection('artifacts')
          .doc(_APP_ID)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .where('userId', isEqualTo: uid)
          .get();

      final batch = db.batch();
      for (final doc in postsSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close loading
      _snack('User deleted successfully', ok: true);
    } catch (e) {
      debugPrint('Delete user error: $e');
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close loading
      _snack('Failed to delete user: $e', ok: false);
    }
  }

  Future<void> _toggleBan(String uid, bool isBanned) async {
    final ok = await _confirmDialog(
      icon: isBanned ? Icons.lock_open_rounded : Icons.lock_rounded,
      iconColor: isBanned ? _successColor : _dangerColor,
      title: isBanned ? 'Unban User?' : 'Ban User?',
      message: isBanned
          ? 'User will regain full access to the app.'
          : 'User will be blocked from accessing the app.',
      confirmLabel: isBanned ? 'Unban' : 'Ban',
      confirmColor: isBanned ? _successColor : _dangerColor,
    );
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid).update({'banned': !isBanned});
      if (mounted) _snack(isBanned ? 'User unbanned' : 'User banned', ok: true);
    } catch (e) {
      if (mounted) _snack('Failed: $e', ok: false);
    }
  }

  Future<void> _toggleAdmin(String uid, bool isAdmin) async {
    final ok = await _confirmDialog(
      icon: isAdmin ? Icons.shield_rounded : Icons.admin_panel_settings_rounded,
      iconColor: _primaryColor,
      title: isAdmin ? 'Remove Admin?' : 'Make Admin?',
      message: isAdmin
          ? 'This user will lose all admin privileges.'
          : 'This user will gain full admin access.',
      confirmLabel: isAdmin ? 'Remove' : 'Promote',
      confirmColor: _primaryColor,
    );
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid).update({'isAdmin': !isAdmin});
      if (mounted) _snack(isAdmin ? 'Admin removed' : 'User promoted to admin', ok: true);
    } catch (e) {
      if (mounted) _snack('Failed: $e', ok: false);
    }
  }

  // ── User detail bottom sheet ─────────────────────────────────────────────────

  void _openUserDetail(String uid, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(
        uid: uid,
        data: data,
        isSelf: uid == _me.uid,
        onBan:        () { Navigator.pop(context); _toggleBan(uid, data['banned'] ?? false); },
        onDelete:     () { Navigator.pop(context); _deleteUser(uid); },
        onToggleAdmin:() { Navigator.pop(context); _toggleAdmin(uid, data['isAdmin'] ?? false); },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ok ? _successColor : _dangerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
            color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
    ));
  }

  Future<bool?> _confirmDialog({
    required IconData icon, required Color iconColor,
    required String title, required String message,
    required String confirmLabel, required Color confirmColor,
  }) => showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.cookie(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _textMuted, fontSize: 14)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            )),
          ]),
        ]),
      ),
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: _dangerColor.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.lock_rounded, color: _dangerColor, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Access Denied', style: GoogleFonts.cookie(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('You do not have admin privileges.', style: TextStyle(color: _textMuted)),
        ])),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Manage Users',
            style: GoogleFonts.cookie(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _primaryColor));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: _dangerColor)));
          }

          final all      = snap.data?.docs ?? [];
          final total    = all.length;
          final banned   = all.where((d) => (d.data() as Map)['banned'] == true).length;
          final admins   = all.where((d) => (d.data() as Map)['isAdmin'] == true).length;
          final active   = total - banned;

          final filtered = _searchQuery.isEmpty
              ? all
              : all.where((doc) {
                  final d    = doc.data() as Map<String, dynamic>;
                  final name = (d['name'] ?? d['email'] ?? '').toString().toLowerCase();
                  final mail = (d['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || mail.contains(_searchQuery);
                }).toList();

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(slivers: [

              // ── Stats row ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(children: [
                    _Stat(icon: Icons.people_rounded,              label: 'Total',   value: '$total',  color: _primaryColor),
                    const SizedBox(width: 8),
                    _Stat(icon: Icons.check_circle_rounded,        label: 'Active',  value: '$active', color: _successColor),
                    const SizedBox(width: 8),
                    _Stat(icon: Icons.block_rounded,               label: 'Banned',  value: '$banned', color: _dangerColor),
                    const SizedBox(width: 8),
                    _Stat(icon: Icons.admin_panel_settings_rounded, label: 'Admins', value: '$admins', color: _infoColor),
                  ]),
                ),
              ),

              // ── Search ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email…',
                        hintStyle: const TextStyle(color: _textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, color: _primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: _textMuted, size: 18),
                                onPressed: _searchCtrl.clear)
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Count label ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                  child: Text(
                    _searchQuery.isEmpty
                        ? '$total users'
                        : '${filtered.length} result${filtered.length == 1 ? '' : 's'} for "$_searchQuery"',
                    style: const TextStyle(color: _textMuted, fontSize: 12),
                  ),
                ),
              ),

              // ── Empty state ─────────────────────────────────────────────
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.person_search_rounded, color: _textMuted.withOpacity(0.35), size: 72),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isEmpty ? 'No users found' : 'No results for "$_searchQuery"',
                      style: const TextStyle(color: _textMuted, fontSize: 16),
                    ),
                  ])),
                ),

              // ── User list ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final doc  = filtered[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return _UserCard(
                        uid:    doc.id,
                        data:   data,
                        isSelf: doc.id == _me.uid,
                        onTap:  () => _openUserDetail(doc.id, data),
                        onBan:  () => _toggleBan(doc.id, data['banned'] ?? false),
                        onDelete: () => _deleteUser(doc.id),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// ─── Stat chip ────────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _Stat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 10)),
      ]),
    ),
  );
}

// ─── User card (list item) ────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;
  final bool isSelf;
  final VoidCallback onTap, onBan, onDelete;

  const _UserCard({
    required this.uid, required this.data, required this.isSelf,
    required this.onTap, required this.onBan, required this.onDelete,
  });

  Color get _avatarColor {
    final palette = [_primaryColor, _infoColor, const Color(0xFFAB47BC),
                     const Color(0xFF26C6DA), _successColor];
    return palette[uid.codeUnitAt(0) % palette.length];
  }

  String get _initials {
    final raw  = (data['name'] ?? data['email'] ?? '?').toString().trim();
    final parts = raw.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return raw.isNotEmpty ? raw[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isBanned = data['banned'] ?? false;
    final isAdmin  = data['isAdmin'] ?? false;
    final name     = data['name'] ?? data['email'] ?? 'Unknown';
    final email    = data['email'] ?? 'No email';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelf
              ? _primaryColor.withOpacity(0.5)
              : isBanned
                  ? _dangerColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.06)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [

            // ── Avatar ─────────────────────────────────────────────────────
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_avatarColor, _avatarColor.withOpacity(0.55)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(_initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              if (isBanned)
                _badge(_dangerColor, Icons.block, -2, null),
              if (!isBanned && isAdmin)
                _badge(_primaryColor, Icons.shield, -2, null),
            ]),

            const SizedBox(width: 14),

            // ── Info ────────────────────────────────────────────────────────
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(name,
                    style: GoogleFonts.cookie(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis)),
                if (isSelf) _pill('You', _primaryColor),
                if (isAdmin && !isSelf) _pill('Admin', _infoColor),
              ]),
              const SizedBox(height: 3),
              Text(email, style: const TextStyle(color: _textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              _statusBadge(isBanned),
            ])),

            const SizedBox(width: 8),

            // ── Actions ─────────────────────────────────────────────────────
            Column(children: [
              _ActionBtn(
                icon: isBanned ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: isBanned ? _successColor : _dangerColor,
                tooltip: isBanned ? 'Unban' : 'Ban',
                onTap: onBan,
              ),
              const SizedBox(height: 6),
              _ActionBtn(
                icon: Icons.delete_rounded,
                color: _dangerColor,
                tooltip: 'Delete',
                onTap: onDelete,
              ),
            ]),

          ]),
        ),
      ),
    );
  }

  Widget _badge(Color c, IconData ic, double right, double? left) => Positioned(
    right: right, bottom: -2,
    child: Container(
      width: 18, height: 18,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _cardColor, width: 2)),
      child: Icon(ic, color: Colors.white, size: 10),
    ),
  );

  Widget _pill(String label, Color c) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _statusBadge(bool isBanned) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isBanned ? _dangerColor.withOpacity(0.15) : _successColor.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(isBanned ? 'Banned' : 'Active',
        style: TextStyle(color: isBanned ? _dangerColor : _successColor, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ─── Action icon button ───────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    ),
  );
}

// ─── User detail bottom sheet ─────────────────────────────────────────────────
class _UserDetailSheet extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> data;
  final bool isSelf;
  final VoidCallback onBan, onDelete, onToggleAdmin;

  const _UserDetailSheet({
    required this.uid, required this.data, required this.isSelf,
    required this.onBan, required this.onDelete, required this.onToggleAdmin,
  });

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  int    _postsCount    = 0;
  int    _totalLikes    = 0;
  int    _savedCount    = 0;
  bool   _loadingStats  = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Posts created by this user
      final postsSnap = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(_APP_ID)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .where('userId', isEqualTo: widget.uid)
          .get();

      int likes = 0;
      for (final doc in postsSnap.docs) {
        final d = doc.data();
        final l = d['likes'];
        if (l is int)  likes += l;
        if (l is List) likes += l.length;
        if (l is Map)  likes += l.length;
      }

      // Saved posts count
      final saved = (widget.data['savedPosts'] as List?)?.length ?? 0;

      if (mounted) {
        setState(() {
          _postsCount   = postsSnap.size;
          _totalLikes   = likes;
          _savedCount   = saved;
          _loadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Stats load error: $e');
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'Unknown';
    try {
      final dt = (ts as Timestamp).toDate();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Unknown';
    }
  }

  String _timeAgo(dynamic ts) {
    if (ts == null) return 'Never';
    try {
      final dt   = (ts as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
      if (diff.inDays > 0)  return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      return 'Just now';
    } catch (_) {
      return 'Unknown';
    }
  }

  Color get _avatarColor {
    final p = [_primaryColor, _infoColor, const Color(0xFFAB47BC),
               const Color(0xFF26C6DA), _successColor];
    return p[widget.uid.codeUnitAt(0) % p.length];
  }

  String get _initials {
    final raw = (widget.data['name'] ?? widget.data['email'] ?? '?').toString().trim();
    final parts = raw.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return raw.isNotEmpty ? raw[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final d        = widget.data;
    final isBanned = d['banned']  ?? false;
    final isAdmin  = d['isAdmin'] ?? false;
    final name     = d['name']  ?? d['email'] ?? 'Unknown';
    final email    = d['email'] ?? 'No email';
    final joined   = _formatDate(d['createdAt']);
    final lastSeen = _timeAgo(d['lastActive']);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(controller: ctrl, padding: EdgeInsets.zero, children: [

          // ── Handle ────────────────────────────────────────────────────────
          Center(child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
          )),

          // ── Avatar + name block ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(children: [
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_avatarColor, _avatarColor.withOpacity(0.55)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(_initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26))),
                ),
                if (isBanned)
                  Positioned(right: -2, bottom: -2,
                    child: Container(width: 22, height: 22,
                      decoration: BoxDecoration(color: _dangerColor, shape: BoxShape.circle,
                          border: Border.all(color: _cardColor, width: 2)),
                      child: const Icon(Icons.block, color: Colors.white, size: 12))),
                if (!isBanned && isAdmin)
                  Positioned(right: -2, bottom: -2,
                    child: Container(width: 22, height: 22,
                      decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle,
                          border: Border.all(color: _cardColor, width: 2)),
                      child: const Icon(Icons.shield, color: Colors.white, size: 12))),
              ]),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(name,
                      style: GoogleFonts.cookie(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis)),
                  if (widget.isSelf)
                    _pill('You', _primaryColor),
                ]),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: _textMuted, fontSize: 13)),
                const SizedBox(height: 6),
                Row(children: [
                  _statusPill(isBanned),
                  if (isAdmin) ...[
                    const SizedBox(width: 6),
                    _pill('Admin', _infoColor),
                  ],
                ]),
              ])),
            ]),
          ),

          const _Divider(),

          // ── Analytics cards ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text('Analytics',
                    style: GoogleFonts.cookie(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              if (_loadingStats)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: _primaryColor),
                ))
              else
                Row(children: [
                  _AnalyticBox(icon: Icons.menu_book_rounded,    label: 'Posts',      value: '$_postsCount',  color: _primaryColor),
                  const SizedBox(width: 10),
                  _AnalyticBox(icon: Icons.favorite_rounded,     label: 'Total Likes', value: '$_totalLikes', color: _dangerColor),
                  const SizedBox(width: 10),
                  _AnalyticBox(icon: Icons.bookmark_rounded,     label: 'Saved',       value: '$_savedCount', color: _infoColor),
                ]),
            ]),
          ),

          const _Divider(),

          // ── Account info ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text('Account Info',
                    style: GoogleFonts.cookie(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              _InfoRow(icon: Icons.fingerprint_rounded,        label: 'UID',         value: widget.uid),
              _InfoRow(icon: Icons.calendar_today_rounded,     label: 'Joined',      value: joined),
              _InfoRow(icon: Icons.access_time_rounded,        label: 'Last Active', value: lastSeen),
              _InfoRow(icon: Icons.phone_android_rounded,      label: 'Provider',
                  value: (d['provider'] ?? 'email').toString()),
            ]),
          ),

          const _Divider(),

          // ── Action buttons ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(children: [

              // Ban / Unban
              _SheetAction(
                icon:  isBanned ? Icons.lock_open_rounded : Icons.lock_rounded,
                label: isBanned ? 'Unban User'            : 'Ban User',
                color: isBanned ? _successColor           : _dangerColor,
                onTap: widget.onBan,
              ),
              const SizedBox(height: 10),

              // Promote / Demote admin
              if (!widget.isSelf)
                _SheetAction(
                  icon:  isAdmin ? Icons.shield_rounded : Icons.admin_panel_settings_rounded,
                  label: isAdmin ? 'Remove Admin'       : 'Make Admin',
                  color: _primaryColor,
                  onTap: widget.onToggleAdmin,
                ),
              if (!widget.isSelf) const SizedBox(height: 10),

              // Delete (never self)
              if (!widget.isSelf)
                _SheetAction(
                  icon:  Icons.delete_forever_rounded,
                  label: 'Delete User',
                  color: _dangerColor,
                  onTap: widget.onDelete,
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _pill(String label, Color c) => Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _statusPill(bool banned) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: banned ? _dangerColor.withOpacity(0.15) : _successColor.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(banned ? 'Banned' : 'Active',
        style: TextStyle(color: banned ? _dangerColor : _successColor, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    height: 1,
    color: Colors.white10,
  );
}

class _AnalyticBox extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _AnalyticBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 10), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    child: Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _primaryColor, size: 17),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    ]),
  );
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
        const Spacer(),
        Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.6), size: 20),
      ]),
    ),
  );
}
