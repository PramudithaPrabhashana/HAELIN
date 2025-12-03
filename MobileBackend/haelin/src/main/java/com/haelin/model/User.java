package com.haelin.model;

public class User {
    private String userId;
    private String userName;
    private String userNic;
    private String userEmail;
    private String userAddress;
    private String userContact;
    private String userPassword;
    private String role;

    // Empty constructor required for Firestore
    public User() {
    }

    public User(String userId, String userName, String userNic, String userEmail,
                String userAddress, String userContact, String userPassword) {
        this.userId = userId;
        this.userName = userName;
        this.userNic = userNic;
        this.userEmail = userEmail;
        this.userAddress = userAddress;
        this.userContact = userContact;
        this.userPassword = userPassword;
        this.role = role;
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserNic() { return userNic; }
    public void setUserNic(String userNic) { this.userNic = userNic; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserAddress() { return userAddress; }
    public void setUserAddress(String userAddress) { this.userAddress = userAddress; }

    public String getUserContact() { return userContact; }
    public void setUserContact(String userContact) { this.userContact = userContact; }

    public String getUserPassword() { return userPassword; }
    public void setUserPassword(String userPassword) { this.userPassword = userPassword; }

    public String getRole() { return role; }
    public void setRole(String userRole) { this.role = role; }
}
