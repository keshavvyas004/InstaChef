import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/chat_screen.dart';
import 'package:instachef/services/presence_service.dart';
import 'package:instachef/screens/recipe_model.dart';

class MessageScreen extends StatefulWidget {
  final Recipe? recipeToShare;
  const MessageScreen({super.key, this.recipeToShare});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Search for users to start new conversation
  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final queryLower = query.toLowerCase();
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final results = usersSnapshot.docs
        .where((doc) {
          final data = doc.data();
          final username = (data['username'] ?? '').toString().toLowerCase();
          return username.contains(queryLower) && doc.id != user?.uid;
        })
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();

    setState(() {
      _searchResults = results;
    });
  }

  // Get or create conversation ID between two users
  Future<String> _getOrCreateConversation(String recipientId, String recipientUsername) async {
    if (user == null) throw Exception('Not logged in');

    // Create a consistent conversation ID (sorted user IDs)
    final ids = [user!.uid, recipientId]..sort();
    final conversationId = '${ids[0]}_${ids[1]}';

    // Check if conversation exists
    final conversationDoc = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .get();

    if (!conversationDoc.exists) {
      // Get current user's username
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final currentUsername = currentUserDoc.data()?['username'] ?? 'Unknown';

      // Create new conversation
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .set({
        'participants': [user!.uid, recipientId],
        'participantNames': {
          user!.uid: currentUsername,
          recipientId: recipientUsername,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return conversationId;
  }

  void _openChat(String recipientId, String recipientUsername) async {
    try {
      final conversationId = await _getOrCreateConversation(recipientId, recipientUsername);
      if (!mounted) return;
      
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _searchResults = [];
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            recipientId: recipientId,
            recipientUsername: recipientUsername,
            recipeToShare: widget.recipeToShare,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color.fromRGBO(15, 29, 37, 1);
    const orange = Color.fromRGBO(247, 158, 27, 1);

    if (user == null) {
      return const Scaffold(
        backgroundColor: darkBlue,
        body: Center(child: Text('Please log in', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: _searchUsers,
              )
            : Text(
                'Messages',
                style: GoogleFonts.cookie(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchResults = [];
                }
              });
            },
          ),
        ],
      ),
      body: _isSearching && _searchResults.isNotEmpty
          ? _buildSearchResults()
          : _buildConversationsList(),
    );
  }

  Widget _buildSearchResults() {
    const orange = Color.fromRGBO(247, 158, 27, 1);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final userResult = _searchResults[index];
        final username = userResult['username'] ?? 'Unknown';
        final userId = userResult['id'];
        final isOnline = userResult['isOnline'] ?? false;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: orange,
                backgroundImage: userResult['profileImageUrl'] != null && userResult['profileImageUrl'].toString().isNotEmpty
                    ? CachedNetworkImageProvider(userResult['profileImageUrl'])
                    : null,
                child: (userResult['profileImageUrl'] == null || userResult['profileImageUrl'].toString().isEmpty)
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromRGBO(25, 45, 55, 1), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(username, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            isOnline ? 'Online' : 'Tap to start conversation',
            style: TextStyle(color: isOnline ? Colors.green : Colors.white54),
          ),
          onTap: () => _openChat(userId, username),
        );
      },
    );
  }

  Widget _buildConversationsList() {
    const orange = Color.fromRGBO(247, 158, 27, 1);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: user!.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: orange));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message_outlined, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                const Text(
                  'No conversations yet',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  icon: const Icon(Icons.search, color: orange),
                  label: const Text('Find users to message', style: TextStyle(color: orange)),
                ),
              ],
            ),
          );
        }

        final conversations = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index].data() as Map<String, dynamic>;
            final participants = List<String>.from(conversation['participants'] ?? []);
            final participantNames = conversation['participantNames'] as Map<String, dynamic>? ?? {};
            
            // Find the other participant
            final recipientId = participants.firstWhere((id) => id != user!.uid, orElse: () => '');
            final recipientUsername = participantNames[recipientId] ?? 'Unknown';
            final lastMessage = conversation['lastMessage'] ?? '';
            final lastMessageTime = conversation['lastMessageTime'] as Timestamp?;

            String timeAgo = '';
            if (lastMessageTime != null) {
              final diff = DateTime.now().difference(lastMessageTime.toDate());
              if (diff.inDays > 0) {
                timeAgo = '${diff.inDays}d ago';
              } else if (diff.inHours > 0) {
                timeAgo = '${diff.inHours}h ago';
              } else if (diff.inMinutes > 0) {
                timeAgo = '${diff.inMinutes}m ago';
              } else {
                timeAgo = 'Just now';
              }
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(recipientId).snapshots(),
              builder: (context, userSnapshot) {
                String profileImageUrl = '';
                bool isOnline = false;
                Timestamp? lastSeen;
                
                if (userSnapshot.hasData && userSnapshot.data != null) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  profileImageUrl = userData?['profileImageUrl'] ?? '';
                  isOnline = userData?['isOnline'] ?? false;
                  lastSeen = userData?['lastSeen'] as Timestamp?;
                }

                return Card(
                  color: const Color.fromRGBO(25, 45, 55, 1),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: orange,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? CachedNetworkImageProvider(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? Text(
                                  recipientUsername.isNotEmpty ? recipientUsername[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color.fromRGBO(25, 45, 55, 1), width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipientUsername,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Online',
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                          style: const TextStyle(color: Colors.white54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isOnline && lastSeen != null)
                          Text(
                            PresenceService.getLastSeenText(lastSeen),
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                      ],
                    ),
                    trailing: Text(
                      timeAgo,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    onTap: () => _openChat(recipientId, recipientUsername),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
