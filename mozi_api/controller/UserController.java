/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package hu.moziprojekt.mozi_api.controller;

import hu.moziprojekt.mozi_api.model.User;
import hu.moziprojekt.mozi_api.service.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/by-email")
    public User getByEmail(@RequestParam String email) {
        return userService.getByEmail(email);
    }
}
