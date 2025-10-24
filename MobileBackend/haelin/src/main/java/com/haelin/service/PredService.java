package com.haelin.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.haelin.model.Prediction;
import com.haelin.repository.PredRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class PredService {
    private static final String COUNTER_COLLECTION = "counters";
    private static final String COUNTER_DOC = "predictionCounter";
    private static final String COUNTER_FIELD = "lastNumber";

    private final Firestore firestore;
    private final PredRepository predictionRepository;

    @Autowired
    public PredService(Firestore firestore, PredRepository predictionRepository) {
        this.firestore = firestore;
        this.predictionRepository = predictionRepository;
    }

    // Public method to be called by controller
    public String createPrediction(Prediction prediction) throws ExecutionException, InterruptedException {
        // Generate sequential ID in a transaction to avoid race conditions
        String newId = generateNextPredictionIdTransaction();
        prediction.setPredID(newId);

        // Save through repository (which uses document(newId).set(prediction))
        predictionRepository.savePredictionWithId(newId, prediction);

        return "Prediction saved with ID " + newId;
    }

    // Transactional counter update — safe for concurrent requests
    private String generateNextPredictionIdTransaction() throws ExecutionException, InterruptedException {
        DocumentReference counterRef = firestore.collection(COUNTER_COLLECTION).document(COUNTER_DOC);

        // Transaction function: read counter, compute next, write new counter, return next number
        ApiFuture<Integer> transactionFuture = firestore.runTransaction(transaction -> {
            DocumentSnapshot snapshot = transaction.get(counterRef).get();

            int next = 1;
            if (snapshot.exists()) {
                Long last = snapshot.getLong(COUNTER_FIELD);
                if (last != null) next = last.intValue() + 1;
            }

            Map<String, Object> update = new HashMap<>();
            update.put(COUNTER_FIELD, next);
            // Use set to create or overwrite the counter doc
            transaction.set(counterRef, update);

            return next;
        });

        int nextNumber = transactionFuture.get(); // this waits for transaction to finish
        return String.format("PR%03d", nextNumber); // PR001, PR002, ...
    }

    // Optional: list all predictions
    public java.util.List<Prediction> getAllPredictions() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> query = firestore.collection("predictions").get();
        QuerySnapshot snapshot = query.get();
        java.util.List<Prediction> list = new java.util.ArrayList<>();
        for (DocumentSnapshot doc : snapshot.getDocuments()) {
            list.add(doc.toObject(Prediction.class));
        }
        return list;
    }

}
