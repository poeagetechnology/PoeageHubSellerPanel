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

      // 🔥 1️⃣ Create Firestore Notification
      await admin.firestore().collection("notifications").add({
        sellerId: sellerId,
        title: "New Order Received 🛒",
        message: "You have received a new order.",
        type: "order",
        orderId: orderId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Notification document created for seller: ${sellerId}`);

      // 🔥 2️⃣ Get Seller FCM Token
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

      // 🔥 3️⃣ Send Push Notification
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
