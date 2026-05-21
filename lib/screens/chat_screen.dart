import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/services/fcm_service.dart';
import 'package:instachef/services/notification_service.dart';
import 'package:instachef/screens/recipe_model.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String recipientId;
  final String recipientUsername;
  final Recipe? recipeToShare;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.recipientId,
    required this.recipientUsername,
    this.recipeToShare,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

  // 🖼️ Profile Images
  String _myProfileImage = '';
  String _recipientProfileImage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileImages();
    
    // Auto-send recipe if provided
    if (widget.recipeToShare != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(recipe: widget.recipeToShare!.toMap());
      });
    }
  }

  Future<void> _fetchProfileImages() async {
    if (user == null) return;

    try {
      // 1. Fetch My Image
      final myDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      // 2. Fetch Recipient Image
      final recipientDoc = await FirebaseFirestore.instance.collection('users').doc(widget.recipientId).get();

      if (mounted) {
        setState(() {
          _myProfileImage = myDoc.data()?['profileImageUrl'] ?? '';
          _recipientProfileImage = recipientDoc.data()?['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching profile images: $e');
    }
  }

  Future<void> _sendMessage({String? text, Map<String, dynamic>? recipe}) async {
    if (user == null) return;

    final messageText = text?.trim() ?? '';
    if (messageText.isEmpty && recipe == null) return;

    // Get current user's username
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final senderName = currentUserDoc.data()?['username'] ?? 'Unknown';

    // Create message
    final messageData = {
      'senderId': user!.uid,
      'senderName': senderName,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'type': recipe != null ? 'recipe' : 'text',
    };

    // Add recipe data if sharing a recipe
    if (recipe != null) {
      messageData['recipeId'] = recipe['id'];
      messageData['recipeTitle'] = recipe['title'];
      messageData['recipeImage'] = (recipe['imageUrls'] as List?)?.isNotEmpty == true 
          ? recipe['imageUrls'][0] 
          : '';
    }

// Add message to conversation
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .add(messageData);

    // ... (existing update logic) ...

    // 🚀 Send Push Notification to Recipient
    _sendNotificationToRecipient(
      senderName: senderName,
      messageText: messageText,
      messageType: messageData['type'] as String,
      recipeTitle: recipe?['title'],
    );


    // Update conversation's last message
    final lastMessagePreview = recipe != null 
        ? '📖 Shared a recipe: ${recipe['title']}'
        : messageText;

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'lastMessage': lastMessagePreview,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _sendNotificationToRecipient({
    required String senderName,
    required String messageText,
    required String messageType,
    String? recipeTitle,
  }) async {
    try {
      // Get recipient's FCM token from their user document
      final recipientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.recipientId)
          .get();

      final recipientToken = recipientDoc.data()?['fcmToken'];

      if (recipientToken != null) {
        String body = messageText;
        if (messageType == 'recipe') {
          body = '📖 Shared a recipe: ${recipeTitle ?? "Recipe"}';
        }

        await FCMService().sendNotification(
          recipientToken: recipientToken,
          title: senderName,
          body: body,
          data: {
            'conversationId': widget.conversationId,
            'senderId': user!.uid,
            'type': 'message',
          },
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _showShareRecipeDialog() async {
    // Fetch user's recipes or all recipes
    final recipesSnapshot = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .limit(20)
        .get();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share a Recipe',
                style: GoogleFonts.cookie(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: recipesSnapshot.docs.isEmpty
                    ? const Center(
                        child: Text(
                          'No recipes found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: recipesSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          final recipe = recipesSnapshot.docs[index].data();
                          final imageUrl = (recipe['imageUrls'] as List?)?.isNotEmpty == true
                              ? recipe['imageUrls'][0]
                              : null;

                          return Card(
                            color: const Color.fromRGBO(25, 45, 55, 1),
                            child: ListTile(
                              leading: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(
                                          Icons.restaurant,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Color.fromRGBO(247, 158, 27, 1),
                                      child: Icon(Icons.restaurant, color: Colors.white),
                                    ),
                              title: Text(
                                recipe['title'] ?? 'Untitled',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'By ${recipe['userName'] ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _sendMessage(recipe: recipe);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color.fromRGBO(15, 29, 37, 1);
    const orange = Color.fromRGBO(247, 158, 27, 1);

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: orange,
              backgroundImage: _recipientProfileImage.isNotEmpty
                  ? CachedNetworkImageProvider(_recipientProfileImage)
                  : null,
              child: _recipientProfileImage.isEmpty
                  ? Text(
                      widget.recipientUsername.isNotEmpty
                          ? widget.recipientUsername[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.recipientUsername,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: orange));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSend a message to start the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == user?.uid;
                    final messageType = message['type'] ?? 'text';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end, // Align avatar to bottom
                        children: [
                          // Recipient Avatar (Left)
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color.fromRGBO(247, 158, 27, 0.2),
                              backgroundImage: _recipientProfileImage.isNotEmpty
                                  ? CachedNetworkImageProvider(_recipientProfileImage)
                                  : null,
                              child: _recipientProfileImage.isEmpty
                                  ? Text(widget.recipientUsername.isNotEmpty ? widget.recipientUsername[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12, color: Colors.white))
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Message Bubble
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: messageType == 'recipe'
                                  ? _buildRecipeMessage(message, isMe)
                                  : _buildTextMessage(message, isMe),
                            ),
                          ),

                          // My Avatar (Right)
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color.fromRGBO(247, 158, 27, 0.2),
                              backgroundImage: _myProfileImage.isNotEmpty
                                  ? CachedNetworkImageProvider(_myProfileImage)
                                  : null,
                              child: _myProfileImage.isEmpty
                                  ? const Icon(Icons.person, size: 16, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(25, 45, 55, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Share recipe button
                IconButton(
                  icon: const Icon(Icons.restaurant_menu, color: orange),
                  onPressed: _showShareRecipeDialog,
                  tooltip: 'Share a recipe',
                ),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: const Color.fromRGBO(35, 55, 65, 1),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (text) => _sendMessage(text: text),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                Container(
                  decoration: const BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(text: _messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isMe) {
    const orange = Color.fromRGBO(247, 158, 27, 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? orange : const Color.fromRGBO(35, 55, 65, 1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
          bottomRight: isMe ? Radius.zero : const Radius.circular(16),
        ),
      ),
      child: Text(
        message['text'] ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget _buildRecipeMessage(Map<String, dynamic> message, bool isMe) {
    const orange = Color.fromRGBO(247, 158, 27, 1);
    final recipeImage = message['recipeImage'] ?? '';
    final recipeTitle = message['recipeTitle'] ?? 'Recipe';

    return Container(
      decoration: BoxDecoration(
        color: isMe ? orange.withOpacity(0.9) : const Color.fromRGBO(35, 55, 65, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipeImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: recipeImage,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 80,
                  color: Colors.grey[800],
                  child: const Icon(Icons.restaurant, color: Colors.white54, size: 40),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📖 Shared a recipe',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  recipeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
