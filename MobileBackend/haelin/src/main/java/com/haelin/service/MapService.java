package com.haelin.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.haelin.model.Hospital;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.ArrayList;
import java.util.List;

@Service
public class MapService {

    private final WebClient webClient = WebClient.create("https://overpass-api.de/api/interpreter");
    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<Hospital> getNearbyHospitals(double lat, double lon, int radius) {

        // Overpass query
        String query =
                "[out:json];" +
                        "node[\"amenity\"=\"hospital\"](around:" + radius + "," + lat + "," + lon + ");" +
                        "out;";

        // Call Overpass
        String responseJson = webClient.get()
                .uri(uriBuilder -> uriBuilder.queryParam("data", query).build())
                .retrieve()
                .bodyToMono(String.class)
                .block();

        return parseHospitals(responseJson);
    }

    private List<Hospital> parseHospitals(String json) {
        List<Hospital> list = new ArrayList<>();

        try {
            JsonNode root = objectMapper.readTree(json);
            JsonNode elements = root.get("elements");

            if (elements != null && elements.isArray()) {
                for (JsonNode node : elements) {

                    double lat = node.get("lat").asDouble();
                    double lon = node.get("lon").asDouble();

                    String name = "Unknown Hospital";
                    if (node.has("tags") && node.get("tags").has("name")) {
                        name = node.get("tags").get("name").asText();
                    }

                    list.add(new Hospital(name, lat, lon));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
