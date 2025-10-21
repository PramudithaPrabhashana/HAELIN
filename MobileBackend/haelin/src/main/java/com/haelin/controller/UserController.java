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
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/user")
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
    public User verifyToken(@RequestHeader("Authorization") String authHeader) throws Exception {
        String idToken = authHeader.replace("Bearer ", "");
        return userService.verifyToken(idToken);
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
    public String updateUser(@PathVariable String uid, @RequestBody User user,
                             @RequestHeader("Authorization") String authHeader) throws ExecutionException, InterruptedException {
        User currentUser = userService.verifyToken(authHeader.replace("Bearer ", ""));
        // Only Admin or the same user can update
        if (!"ADMIN".equalsIgnoreCase(currentUser.getUserRole()) && !currentUser.getUserId().equals(uid)) {
            return "Access denied: You cannot update this user";
        }
        return userService.updateUser(uid, user);
    }

    // =================== DELETE USER ===================
    @DeleteMapping("/delete/{uid}")
    public String deleteUser(@PathVariable String uid, @RequestHeader("Authorization") String authHeader) throws ExecutionException, InterruptedException {
        User currentUser = userService.verifyToken(authHeader.replace("Bearer ", ""));
        // Only Admin can delete
        if (!"ADMIN".equalsIgnoreCase(currentUser.getUserRole())) {
            return "Access denied: Admins only";
        }
        return userService.deleteUser(uid);
    }

    // =================== LOGIN (client handles Firebase Auth) ===================
    // Optional endpoint if you want server-side verification
    @PostMapping("/login")
    public String login(@RequestBody UserLoginRequest request) throws Exception {
        // Client usually handles login with Firebase Auth directly
        return "Use Firebase Auth client SDK to login. Send ID token to backend for verification.";
    }
}
