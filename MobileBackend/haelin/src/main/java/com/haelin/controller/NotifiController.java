package com.haelin.controller;

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
    public String createNotification(@RequestBody Notification notification) throws ExecutionException, InterruptedException {
        return notificationService.saveNotification(notification);
    }

    @GetMapping("/all")
    public List<Notification> getAllNotifications() throws ExecutionException, InterruptedException {
        return notificationService.getAllNotifications();
    }

    @DeleteMapping("delete/{docId}")
    public String deleteNotification(@PathVariable String docId) throws ExecutionException, InterruptedException {
        return notificationService.deleteNotification(docId);
    }
}

