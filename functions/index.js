/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function: Send push notification when a new message is created
 * Triggers on: conversations/{conversationId}/messages/{messageId}
 */
exports.sendMessageNotification = onDocumentCreated(
    "conversations/{conversationId}/messages/{messageId}",
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
        logger.log("No data associated with the event");
        return;
      }

      const messageData = snapshot.data();
      const conversationId = event.params.conversationId;
      const senderId = messageData.senderId;
      const senderName = messageData.senderName || "Someone";
      const messageText = messageData.text || "";
      const messageType = messageData.type || "text";

      logger.log(`New message in conversation ${conversationId} from ${senderId}`);

      try {
        // Get the conversation to find participants
        const conversationDoc = await admin.firestore()
            .collection("conversations")
            .doc(conversationId)
            .get();

        if (!conversationDoc.exists) {
          logger.log("Conversation not found");
          return;
        }

        const participants = conversationDoc.data().participants || [];

        // Find the recipient (the participant who is NOT the sender)
        const recipientId = participants.find((id) => id !== senderId);

        if (!recipientId) {
          logger.log("No recipient found");
          return;
        }

        // Get recipient's FCM token
        const recipientDoc = await admin.firestore()
            .collection("users")
            .doc(recipientId)
            .get();

        if (!recipientDoc.exists) {
          logger.log("Recipient user not found");
          return;
        }

        const fcmToken = recipientDoc.data().fcmToken;

        if (!fcmToken) {
          logger.log("Recipient has no FCM token");
          return;
        }

        // Build notification payload
        let notificationBody = messageText;
        if (messageType === "recipe") {
          notificationBody = `📖 Shared a recipe: ${messageData.recipeTitle || "Recipe"}`;
        }

        const message = {
          token: fcmToken,
          notification: {
            title: senderName,
            body: notificationBody || "Sent you a message",
          },
          data: {
            conversationId: conversationId,
            senderId: senderId,
            type: "message",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "messages_channel",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        // Send the notification
        const response = await admin.messaging().send(message);
        logger.log("Successfully sent notification:", response);
      } catch (error) {
        logger.error("Error sending notification:", error);
      }
    },
);
