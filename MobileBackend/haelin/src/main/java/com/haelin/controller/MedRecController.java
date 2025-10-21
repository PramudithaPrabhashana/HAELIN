package com.haelin.controller;


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

    @PostMapping
    public String createOrUpdateRecord(@RequestBody MedRec medRec) throws ExecutionException, InterruptedException {
        return medRecService.saveRecord(medRec);
    }

    @GetMapping
    public List<MedRec> getAllRecords() throws ExecutionException, InterruptedException {
        return medRecService.getAllRecords();
    }

    @GetMapping("/{id}")
    public MedRec getRecordById(@PathVariable String id) throws ExecutionException, InterruptedException {
        return medRecService.getRecordById(id);
    }

    @DeleteMapping("/{id}")
    public String deleteRecord(@PathVariable String id) {
        return medRecService.deleteRecord(id);
    }
}
