/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package hu.patrik.mozi.controller;

import hu.patrik.mozi.dto.LoginRequest;
import hu.patrik.mozi.dto.LoginResponse;
import hu.patrik.mozi.model.User;
import hu.patrik.mozi.security.JwtUtil;
import hu.patrik.mozi.service.UserService;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.Optional;

@Path("/auth")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AuthController {

    @Inject
    private UserService userService;

    @POST
    @Path("/login")
    public Response login(LoginRequest req) {

        if (req == null || req.getEmail() == null || req.getEmail().isBlank()
                || req.getPassword() == null || req.getPassword().isBlank()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("email and password required")
                    .build();
        }

        Optional<User> user = userService.authenticate(req.getEmail(), req.getPassword());

        if (user.isEmpty()) {
            return Response.status(Response.Status.UNAUTHORIZED)
                    .entity("invalid credentials")
                    .build();
        }

        String token = JwtUtil.generateToken(user.get().getEmail(), user.get().getRole());
        return Response.ok(new LoginResponse(token, JwtUtil.EXP_SECONDS)).build();
    }
}
