package com.haelin.service;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class MapService {
    private final WebClient webClient = WebClient.create("https://overpass-api.de/api/interpreter");

    public String getNearbyHospitals(double lat, double lon, int radius) {
        String query = "[out:json];" +
                "node[\"amenity\"=\"hospital\"](around:" + radius + "," + lat + "," + lon + ");" +
                "out;";
        return webClient.get()
                .uri(uriBuilder -> uriBuilder.queryParam("data", query).build())
                .retrieve()
                .bodyToMono(String.class)
                .block();
    }
}

