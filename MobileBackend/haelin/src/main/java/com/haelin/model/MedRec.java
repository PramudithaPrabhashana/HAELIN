package com.haelin.model;

public class MedRec {

    private String medID;
    private String diagnosis;
    private String riskStatus;
    private String date;
    private String symptoms;
    private Double predScore;

    public MedRec() {}

    public MedRec(String medID, String diagnosis, String riskStatus, String date, String symptoms, double predScore) {
        this.medID = medID;
        this.diagnosis = diagnosis;
        this.riskStatus = riskStatus;
        this.date = date;
        this.symptoms = symptoms;
        this.predScore = predScore;
    }

    // Getters and setters
    public String getMedID() { return medID; }
    public void setMedID(String medID) { this.medID = medID; }

    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }

    public String getRiskStatus() { return riskStatus; }
    public void setRiskStatus(String riskStatus) { this.riskStatus = riskStatus; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public Double getPredScore() { return predScore; }
    public void setPredScore(double predScore) { this.predScore = predScore; }

}
