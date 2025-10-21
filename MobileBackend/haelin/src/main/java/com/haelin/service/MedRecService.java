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

    // Create or Update
    public String saveRecord(MedRec medRec) throws ExecutionException, InterruptedException {
        Firestore db = FirestoreClient.getFirestore();

        if (medRec.getMedID() == null || medRec.getMedID().isEmpty()) {
            medRec.setMedID(UUID.randomUUID().toString());
        }

        ApiFuture<WriteResult> writeResult = db.collection(COLLECTION_NAME)
                .document(medRec.getMedID())
                .set(medRec);

        return "Record saved at: " + writeResult.get().getUpdateTime();
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
