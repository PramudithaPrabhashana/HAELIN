package com.haelin.controller;

import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.haelin.model.User;
import com.haelin.model.UserLoginRequest;
import com.haelin.service.UserService;
import com.google.firebase.auth.UserRecord;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/user")
@CrossOrigin(origins = {"http://127.0.0.1:5580", "http://localhost:5580"})
public class UserController {

    @Autowired
    private UserService userService;

    // =================== SIGNUP ===================
    @PostMapping("/signup")
    public String signup(@RequestBody User user) throws Exception {
        return userService.signup(user);
    }

    // =================== VERIFY TOKEN ===================
    @PostMapping("/verify")
    public ResponseEntity<?> verifyToken(@RequestHeader("Authorization") String authHeader) {
        try {
            String idToken = authHeader.replace("Bearer ", "");
            User user = userService.verifyToken(idToken);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Token verification failed: " + e.getMessage());
        }
    }

    // =================== LOGIN - Verify Firebase Token ===================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody UserLoginRequest request) {
        try {
            String idToken = request.getIdToken();

            if (idToken == null || idToken.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("ID token is required");
            }

            User user = userService.verifyToken(idToken);

            // Check if user is admin
            if ("ADMIN".equalsIgnoreCase(user.getUserRole())) {
                Map<String, Object> response = new HashMap<>();
                response.put("message", "Login successful");
                response.put("user", user);
                response.put("isAdmin", true);

                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Access denied: Admin privileges required");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Login failed: " + e.getMessage());
        }
    }

    // =================== GET ALL USERS (ADMIN ONLY) ===================
    @GetMapping("/all")
    public List<User> getAllUsers(@RequestHeader("Authorization") String authHeader) throws Exception {
        User currentUser = userService.verifyToken(authHeader.replace("Bearer ", ""));
        if (!"ADMIN".equalsIgnoreCase(currentUser.getUserRole())) {
            throw new RuntimeException("Access denied: Admins only");
        }

        Firestore db = FirestoreClient.getFirestore();
        List<User> userList = new ArrayList<>();
        for (DocumentSnapshot doc : db.collection("users").get().get().getDocuments()) {
            userList.add(doc.toObject(User.class));
        }
        return userList;
    }

    // =================== UPDATE USER ===================
    @PutMapping("/update/{uid}")
    public ResponseEntity<?> updateUser(@PathVariable String uid, @RequestBody User user,
                                        @RequestHeader("Authorization") String authHeader) {
        try {
            User currentUser = userService.verifyToken(authHeader.replace("Bearer ", ""));

            // Only Admin or the same user can update
            if (!"ADMIN".equalsIgnoreCase(currentUser.getUserRole()) && !currentUser.getUserId().equals(uid)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Access denied: You cannot update this user");
            }

            String result = userService.updateUser(uid, user);
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Token verification failed: " + e.getMessage());
        }
    }

    // =================== DELETE USER ===================
    @DeleteMapping("/delete/{uid}")
    public ResponseEntity<?> deleteUser(@PathVariable String uid,
                                        @RequestHeader("Authorization") String authHeader) {
        try {
            User currentUser = userService.verifyToken(authHeader.replace("Bearer ", ""));

            // Only Admin can delete
            if (!"ADMIN".equalsIgnoreCase(currentUser.getUserRole())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Access denied: Admins only");
            }

            String result = userService.deleteUser(uid);
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Token verification failed: " + e.getMessage());
        }
    }
}