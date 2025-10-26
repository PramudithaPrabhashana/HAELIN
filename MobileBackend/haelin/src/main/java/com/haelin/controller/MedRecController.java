package com.haelin.controller;


import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.haelin.model.MedRec;
import com.haelin.service.MedRecService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/medrec")
public class MedRecController {

    @Autowired
    private MedRecService medRecService;

    @PostMapping("/add")
    public String createRecord(@RequestHeader("Authorization") String authHeader,
                               @RequestBody MedRec medRec)
            throws ExecutionException, InterruptedException {

        // Extract and verify Firebase ID token
        String idToken = authHeader.replace("Bearer ", "");

        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();      // Extract UID
            medRec.setUserId(uid);                   // Assign UID as userId

            return medRecService.createRecord(medRec);

        } catch (Exception e) {
            return "Invalid or expired Firebase token: " + e.getMessage();
        }
    }

    @PutMapping("/update/{id}")
    public String updateRecord(@PathVariable String id, @RequestBody MedRec medRec)
            throws ExecutionException, InterruptedException {
        return medRecService.updateRecord(id, medRec);
    }
    @GetMapping("/all")
    public List<MedRec> getAllRecords() throws ExecutionException, InterruptedException {
        return medRecService.getAllRecords();
    }

    //Get only records belonging to the logged-in user
    @GetMapping("/user")
    public List<MedRec> getRecordsByUser(@RequestHeader("Authorization") String authHeader)
            throws ExecutionException, InterruptedException, FirebaseAuthException {
        String idToken = authHeader.replace("Bearer ", "");
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        String uid = decodedToken.getUid();

        return medRecService.getRecordsByUserId(uid);
    }

    @GetMapping("{id}")
    public MedRec getRecordById(@PathVariable String id) throws ExecutionException, InterruptedException {
        return medRecService.getRecordById(id);
    }

    @DeleteMapping("delete/{id}")
    public String deleteRecord(@PathVariable String id) {
        return medRecService.deleteRecord(id);
    }
}
