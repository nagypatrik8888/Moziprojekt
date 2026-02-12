/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package hu.patrik.mozi.dto;

public class LoginResponse {

    private String token;
    private String type = "Bearer";
    private long expiresInSeconds;

    public LoginResponse() {}

    public LoginResponse(String token, long expiresInSeconds) {
        this.token = token;
        this.expiresInSeconds = expiresInSeconds;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public long getExpiresInSeconds() { return expiresInSeconds; }
    public void setExpiresInSeconds(long expiresInSeconds) { this.expiresInSeconds = expiresInSeconds; }
}
