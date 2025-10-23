package com.haelin.controller;

import com.haelin.model.Prediction;
import com.haelin.service.PredService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/prediction")
@CrossOrigin
public class PredController {
    private final PredService predictionService;

    @Autowired
    public PredController(PredService predictionService) {
        this.predictionService = predictionService;
    }

    // Endpoint for FastAPI to POST prediction result
    @PostMapping("/add")
    public String addPrediction(@RequestBody Prediction prediction) throws ExecutionException, InterruptedException {
        // Note: predID will be generated here
        return predictionService.createPrediction(prediction);
    }

    // Optional: view all predictions
    @GetMapping("/all")
    public List<Prediction> getAll() throws ExecutionException, InterruptedException {
        return predictionService.getAllPredictions();
    }
}
