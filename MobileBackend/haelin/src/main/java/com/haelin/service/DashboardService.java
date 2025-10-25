package com.haelin.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class DashboardService {

    private static final String USER_COLLECTION = "users";
    private static final String RECORD_COLLECTION = "medical_records";

    public long getUserCount() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(USER_COLLECTION).get();
        return query.get().size();
    }

    public long getTotalCases() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(RECORD_COLLECTION).get();
        return query.get().size();
    }

    public long getDengueCases() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(RECORD_COLLECTION)
                .whereEqualTo("diagnosis", "Dengue")
                .get();
        return query.get().size();
    }

    public long getChikungunyaCases() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(RECORD_COLLECTION)
                .whereEqualTo("diagnosis", "Chikungunya")
                .get();
        return query.get().size();
    }
}
