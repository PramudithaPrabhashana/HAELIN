package com.haelin.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.haelin.model.Notification;
import com.haelin.service.NotifiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/notification")
public class NotifiController {

    @Autowired
    private NotifiService notificationService;

    @PostMapping("/add")
    public String createNotification(@RequestHeader("Authorization") String authHeader,
                                     @RequestBody Notification notification)
            throws ExecutionException, InterruptedException {
        try {
            String token = authHeader.replace("Bearer ", "");
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
            String userId = decodedToken.getUid();
            notification.setUserId(userId); // link to Firebase user

            return notificationService.saveNotification(notification);
        } catch (FirebaseAuthException e) {
            return "Invalid or expired token: " + e.getMessage();
        }
    }

    @GetMapping("/all")
    public List<Notification> getAllNotifications() throws ExecutionException, InterruptedException {
        return notificationService.getAllNotifications();
    }

    // Get notifications for logged-in user
    @GetMapping("/my")
    public List<Notification> getUserNotifications(@RequestHeader("Authorization") String authHeader)
            throws ExecutionException, InterruptedException {
        try {
            String token = authHeader.replace("Bearer ", "");
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
            String userId = decodedToken.getUid();
            return notificationService.getNotificationsByUser(userId);
        } catch (FirebaseAuthException e) {
            throw new RuntimeException("Invalid token: " + e.getMessage(), e);
        }
    }

    @DeleteMapping("delete/{docId}")
    public String deleteNotification(@PathVariable String docId) throws ExecutionException, InterruptedException {
        return notificationService.deleteNotification(docId);
    }
}

