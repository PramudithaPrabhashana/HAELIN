package com.haelin.controller;

import com.haelin.model.Hospital;
import com.haelin.service.MapService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/map")
public class MapController {

    private final MapService mapService;

    public MapController(MapService mapService) {
        this.mapService = mapService;
    }

    @GetMapping("/hospitals")
    public ResponseEntity<List<Hospital>> getNearbyHospitals(
            @RequestParam double lat,
            @RequestParam double lon,
            @RequestParam(defaultValue = "5000") int radius) {

        List<Hospital> result = mapService.getNearbyHospitals(lat, lon, radius);
        return ResponseEntity.ok(result);
    }
}
