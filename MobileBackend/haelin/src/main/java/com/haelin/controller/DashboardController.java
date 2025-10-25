package com.haelin.controller;

import com.haelin.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    @GetMapping("/stats")
    public Map<String, Object> getDashboardStats() throws ExecutionException, InterruptedException {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", dashboardService.getUserCount());
        stats.put("totalCases", dashboardService.getTotalCases());
        stats.put("dengueCases", dashboardService.getDengueCases());
        stats.put("chikungunyaCases", dashboardService.getChikungunyaCases());
        return stats;
    }
}
