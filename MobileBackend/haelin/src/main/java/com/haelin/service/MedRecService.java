package com.haelin.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.haelin.model.MedRec;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ExecutionException;

@Service
public class MedRecService {

    private static final String COLLECTION_NAME = "medical_records";

    // Create record
    public String createRecord(MedRec medRec) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();

        // Generate new ID for each new record
        String newId = UUID.randomUUID().toString();
        medRec.setMedID(newId);

        ApiFuture<WriteResult> writeResult = db.collection(COLLECTION_NAME)
                .document(newId)
                .set(medRec);

        return "New record created at: " + writeResult.get().getUpdateTime();
    }

    //Update
    public String updateRecord(String id, MedRec medRec) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(id);

        ApiFuture<DocumentSnapshot> future = docRef.get();
        DocumentSnapshot document = future.get();

        if (!document.exists()) {
            return "Record with ID " + id + " not found.";
        }

        Map<String, Object> updates = new HashMap<>();

        if (medRec.getDiagnosis() != null) updates.put("diagnosis", medRec.getDiagnosis());
        if (medRec.getRiskStatus() != null) updates.put("riskStatus", medRec.getRiskStatus());
        if (medRec.getDate() != null) updates.put("date", medRec.getDate());
        if (medRec.getSymptoms() != null) updates.put("symptoms", medRec.getSymptoms());
        if (medRec.getPredScore() != null) updates.put("predScore", medRec.getPredScore());

        if (updates.isEmpty()) {
            return "No fields to update for record ID " + id;
        }

        ApiFuture<WriteResult> writeResult = docRef.update(updates);
        return "Record updated at: " + writeResult.get().getUpdateTime();
    }

    // Get all records
    public List<MedRec> getAllRecords() throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> query = db.collection(COLLECTION_NAME).get();
        List<QueryDocumentSnapshot> docs = query.get().getDocuments();

        List<MedRec> records = new ArrayList<>();
        for (QueryDocumentSnapshot doc : docs) {
            records.add(doc.toObject(MedRec.class));
        }
        return records;
    }

    // Get one record
    public MedRec getRecordById(String medID) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection(COLLECTION_NAME).document(medID);
        DocumentSnapshot document = docRef.get().get();

        return document.exists() ? document.toObject(MedRec.class) : null;
    }

    // Delete record
    public String deleteRecord(String medID) {
        Firestore db = FirestoreClient.getFirestore();
        db.collection(COLLECTION_NAME).document(medID).delete();
        return "Record with ID " + medID + " deleted successfully.";
    }
}
