package com.haelin.repository;

import com.google.cloud.firestore.Firestore;
import com.haelin.model.Prediction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.concurrent.ExecutionException;

@Repository
public class PredRepository {
    private final Firestore firestore;

    @Autowired
    public PredRepository(Firestore firestore) {
        this.firestore = firestore;
    }

    public void savePredictionWithId(String id, Prediction prediction) throws ExecutionException, InterruptedException {
        // The .get() ensures the operation completes (writes) before returning.
        firestore.collection("predictions")
                .document(id)
                .set(prediction)
                .get();
    }
}
