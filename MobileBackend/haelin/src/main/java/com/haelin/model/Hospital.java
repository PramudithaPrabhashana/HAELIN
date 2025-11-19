package com.haelin.model;

public class Hospital {
    private String name;
    private double lat;
    private double lon;

    public Hospital() {}

    public Hospital(String name, double lat, double lon) {
        this.name = name;
        this.lat = lat;
        this.lon = lon;
    }

    public String getName() { return name; }
    public double getLat() { return lat; }
    public double getLon() { return lon; }

    public void setName(String name) { this.name = name; }
    public void setLat(double lat) { this.lat = lat; }
    public void setLon(double lon) { this.lon = lon; }
}
