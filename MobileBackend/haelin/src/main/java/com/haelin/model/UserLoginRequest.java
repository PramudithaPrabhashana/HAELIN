package com.haelin.model;

public class UserLoginRequest {
    private String idToken;  // Change from userEmail/userPassword to idToken

    // Default constructor
    public UserLoginRequest() {}

    // Constructor
    public UserLoginRequest(String idToken) {
        this.idToken = idToken;
    }

    // Getters and setters
    public String getIdToken() {
        return idToken;
    }

    public void setIdToken(String idToken) {
        this.idToken = idToken;
    }
}