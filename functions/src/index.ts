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

      await admin.firestore().collection("notifications").add({
        sellerId: sellerId, // MUST match seller FirebaseAuth UID
        title: "New Order Received 🛒",
        message: "You have received a new order.",
        type: "order",
        orderId: event.params.orderId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(
        `Notification created successfully for seller: ${sellerId}`
      );
    } catch (error) {
      console.error("Error creating notification:", error);
    }
  }
);
