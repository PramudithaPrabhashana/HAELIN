package com.haelin.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.haelin.model.Notification;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class NotifiService {

    private static final String COLLECTION_NAME = "notifications";

    // Create
    public String saveNotification(Notification notification) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();

        ApiFuture<WriteResult> writeResult = db.collection(COLLECTION_NAME)
                .document()
                .set(notification);

        return "Notification added at: " + writeResult.get().getUpdateTime();
    }

    // Read all
    public List<Notification> getAllNotifications() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(COLLECTION_NAME).get();
        List<QueryDocumentSnapshot> documents = query.get().getDocuments();

        List<Notification> notifications = new ArrayList<>();
        for (QueryDocumentSnapshot document : documents) {
            notifications.add(document.toObject(Notification.class));
        }
        return notifications;
    }

    // Get notifications for a specific userId
    public List<Notification> getNotificationsByUser(String userId) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(COLLECTION_NAME)
                .whereEqualTo("userId", userId)
                .get();

        List<QueryDocumentSnapshot> documents = query.get().getDocuments();
        List<Notification> notifications = new ArrayList<>();
        for (QueryDocumentSnapshot document : documents) {
            notifications.add(document.toObject(Notification.class));
        }
        return notifications;
    }

    // Delete
    public String deleteNotification(String docId) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> writeResult = db.collection(COLLECTION_NAME).document(docId).delete();
        return "Notification deleted at: " + writeResult.get().getUpdateTime();
    }
}

