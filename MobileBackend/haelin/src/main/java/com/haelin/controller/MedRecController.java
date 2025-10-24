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

    @PostMapping("/add")
    public String createRecord(@RequestBody MedRec medRec) throws ExecutionException, InterruptedException {
        return medRecService.createRecord(medRec);
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

    @GetMapping("{id}")
    public MedRec getRecordById(@PathVariable String id) throws ExecutionException, InterruptedException {
        return medRecService.getRecordById(id);
    }

    @DeleteMapping("delete/{id}")
    public String deleteRecord(@PathVariable String id) {
        return medRecService.deleteRecord(id);
    }
}
