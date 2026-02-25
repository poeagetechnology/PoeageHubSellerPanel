import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {setGlobalOptions} from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();
setGlobalOptions({maxInstances: 10});

export const createNotificationOnNewOrder = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    try {
      const snapshot = event.data;

      if (!snapshot) {
        console.log("No order snapshot found");
        return;
      }

      const orderData = snapshot.data();
      if (!orderData) {
        console.log("Order data is empty");
        return;
      }

      const sellerId = orderData.sellerId;
      if (!sellerId) {
        console.log("No sellerId found in order document");
        return;
      }

      const orderId = event.params.orderId;

      const notificationRef = admin
        .firestore()
        .collection("notifications")
        .doc(sellerId)
        .collection("notifications")
        .doc();

      // Create Firestore Notification (Correct Structure)
      await notificationRef.set({
        notificationId: notificationRef.id,
        title: "New Order Received 🛒",
        message: "You have received a new order.",
        type: "order",
        orderId: orderId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Notification created for seller: ${sellerId}`);

      //  Get Seller FCM Token
      const sellerDoc = await admin
        .firestore()
        .collection("sellers")
        .doc(sellerId)
        .get();

      const sellerData = sellerDoc.data();

      if (!sellerData || !sellerData.fcmToken) {
        console.log("No FCM token found for seller");
        return;
      }

      const fcmToken = sellerData.fcmToken;

      // Send Push Notification
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: "New Order Received 🛒",
          body: "You have received a new order.",
        },
        data: {
          orderId: orderId,
          type: "order",
        },
      });

      console.log("Push notification sent successfully");
    } catch (error) {
      console.error("Error creating notification:", error);
    }
  }
);
