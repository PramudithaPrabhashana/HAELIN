package com.haelin.model;

import java.util.Date;

public class User {
    private String userId;
    private String name;
    private String nic;
    private String email;
    private String city;
    private String contact;
    private String password;
    private String role;
    private Date createdAt;

    // Empty constructor required for Firestore
    public User() {
    }

    public User(String userId, String name, String nic, String email,
                String city, String contact, String password, Date createdAt) {
        this.userId = userId;
        this.name = name;
        this.nic = nic;
        this.email = email;
        this.city = city;
        this.contact = contact;
        this.password = password;
        this.role = role;
        this.createdAt = createdAt;
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getNic() { return nic; }
    public void setNic(String nic) { this.nic = nic; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Date getCreatedAt() {return createdAt;}
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
