package com.haelin.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.auth.UserRecord;
import com.google.firebase.cloud.FirestoreClient;
import com.haelin.model.User;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class UserService {

    private static final String COLLECTION_NAME = "users";



    // Add a new user
    public String signup(User user) throws Exception {
        // Validate role
        if (!"ADMIN".equalsIgnoreCase(user.getUserRole()) && !"PATIENT".equalsIgnoreCase(user.getUserRole())) {
            return "Invalid role. Must be either ADMIN or PATIENT.";
        }

        // 1. Create user in Firebase Auth
        UserRecord.CreateRequest request = new UserRecord.CreateRequest()
                .setEmail(user.getUserEmail())
                .setPassword(user.getUserPassword());

        UserRecord firebaseUser = FirebaseAuth.getInstance().createUser(request);
        String uid = firebaseUser.getUid();

        // 2. Store additional details in Firestore
        user.setUserId(uid);           // use Firebase UID as doc ID
        user.setUserPassword(null);    // don't store password in Firestore
        Firestore db = FirestoreClient.getFirestore();
        db.collection("users").document(uid).set(user).get();

        return "User created successfully with UID: " + uid + " and role: " + user.getUserRole();
    }



    // Get a single user by UID
    public User getUser(String uid) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(uid);
        DocumentSnapshot snapshot = docRef.get().get();
        if (snapshot.exists()) {
            return snapshot.toObject(User.class);
        }
        return null;
    }

    // Get all users
    public List<User> getAllUsers() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(COLLECTION_NAME).get();
        List<QueryDocumentSnapshot> documents = query.get().getDocuments();

        List<User> userList = new ArrayList<>();
        for (QueryDocumentSnapshot doc : documents) {
            userList.add(doc.toObject(User.class));
        }
        return userList;
    }

    // Update a user by UID
    public String updateUser(String userId, User user) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(userId);

        DocumentSnapshot snapshot = docRef.get().get();
        if (!snapshot.exists()) {
            return "User with ID " + userId + " does not exist.";
        }

        // Build a map of only non-null fields
        Map<String, Object> updates = new HashMap<>();
        if (user.getUserName() != null) updates.put("userName", user.getUserName());
        if (user.getUserNic() != null) updates.put("userNic", user.getUserNic());
        if (user.getUserEmail() != null) updates.put("userEmail", user.getUserEmail());
        if (user.getUserAddress() != null) updates.put("userAddress", user.getUserAddress());
        if (user.getUserContact() != null) updates.put("userContact", user.getUserContact());
        if (user.getUserPassword() != null) updates.put("userPassword", user.getUserPassword());

        if (updates.isEmpty()) {
            return "No fields to update.";
        }

        ApiFuture<WriteResult> writeResult = docRef.update(updates);
        return "User " + userId + " updated at: " + writeResult.get().getUpdateTime();
    }



    // Delete a user by UID
    public String deleteUser(String userId) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(userId);

        DocumentSnapshot snapshot = docRef.get().get();
        if (!snapshot.exists()) {
            return "User with ID " + userId + " does not exist.";
        }

        ApiFuture<WriteResult> writeResult = docRef.delete();
        return "User " + userId + " deleted at: " + writeResult.get().getUpdateTime();
    }

    public User verifyToken(String idToken) throws Exception {
        if (idToken == null || idToken.trim().isEmpty()) {
            throw new Exception("ID token is required");
        }

        // 1️⃣ Verify Firebase ID token
        FirebaseToken decodedToken;
        try {
            decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        } catch (Exception e) {
            throw new Exception("Invalid or expired Firebase token: " + e.getMessage());
        }

        String uid = decodedToken.getUid();

        // 2️⃣ Fetch the user from Firestore
        Firestore db = FirestoreClient.getFirestore();
        DocumentSnapshot doc;
        try {
            doc = db.collection("users").document(uid).get().get();
        } catch (Exception e) {
            throw new Exception("Error fetching user from Firestore: " + e.getMessage());
        }

        if (!doc.exists()) {
            throw new Exception("User not found in Firestore for UID: " + uid);
        }

        User user = doc.toObject(User.class);
        if (user == null) {
            throw new Exception("Failed to parse Firestore user data");
        }

        // 3️⃣ Optional: Log if token email differs from Firestore email
        if (user.getUserEmail() != null &&
                !user.getUserEmail().trim().equalsIgnoreCase(decodedToken.getEmail().trim())) {
            System.out.println("⚠️ Warning: token email and Firestore email differ");
        }

        // 4️⃣ Return user object
        return user;
    }


}
