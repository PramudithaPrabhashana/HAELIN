package com.haelin.model;

public class Prediction {
    private String predID;
    private Double predScore;
    private String predDate;
    private String predDisease;

    public Prediction() {}

    public Prediction(String predID, Double predScore, String predDate, String predDisease) {
        this.predID = predID;
        this.predScore = predScore;
        this.predDate = predDate;
        this.predDisease = predDisease;
    }

    public String getPredID() { return predID; }
    public void setPredID(String predID) { this.predID = predID; }

    public Double getPredScore() { return predScore; }
    public void setPredScore(Double predScore) { this.predScore = predScore; }

    public String getPredDate() { return predDate; }
    public void setPredDate(String predDate) { this.predDate = predDate; }

    public String getPredDisease() { return predDisease; }
    public void setPredDisease(String predDisease) { this.predDisease = predDisease; }
}
