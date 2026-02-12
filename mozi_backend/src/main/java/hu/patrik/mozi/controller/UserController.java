package hu.patrik.mozi.controller;

import hu.patrik.mozi.model.User;
import hu.patrik.mozi.service.UserService;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.List;

@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
public class UserController {

    @Inject
    private UserService userService;

    @GET
    public List<User> all() {
        return userService.findAll();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    public User create(User user) {
        user.setId(null);

        if (user.getFirstname() == null || user.getFirstname().isBlank()) {
            throw new IllegalArgumentException("firstname is required");
        }
        if (user.getLastname() == null || user.getLastname().isBlank()) {
            throw new IllegalArgumentException("lastname is required");
        }
        if (user.getEmail() == null || user.getEmail().isBlank()) {
            throw new IllegalArgumentException("email is required");
        }
        if (user.getPassword() == null || user.getPassword().isBlank()) {
            throw new IllegalArgumentException("password is required");
        }

        if (user.getRole() == null || user.getRole().isBlank()) {
            user.setRole("USER");
        }

        return userService.create(user);
    }
}
