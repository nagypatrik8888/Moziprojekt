/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package hu.patrik.mozi.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

public class JwtUtil {

    // 15 perc
    public static final long EXP_MS = 15L * 60L * 1000L;
    public static final long EXP_SECONDS = 15L * 60L;

    private static final String SECRET = "CSERELD_LE_EGY_HOSSZU_32+_KARAKTERES_SECRETRE_!!!!";

    private static Key key() {
        return Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));
    }

    public static String generateToken(String email, String role) {
        long now = System.currentTimeMillis();
        Date issuedAt = new Date(now);
        Date exp = new Date(now + EXP_MS);

        return Jwts.builder()
        .subject(email)
        .issuedAt(issuedAt)
        .expiration(exp)
        .claim("role", role)
        .signWith(key())
        .compact();
    }
}

