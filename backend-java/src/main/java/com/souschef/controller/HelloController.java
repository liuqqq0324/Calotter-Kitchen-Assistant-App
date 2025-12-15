package com.souschef.controller;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/hello")
@CrossOrigin(origins = "*")
public class HelloController {
    
    @GetMapping
    public Map<String, Object> get() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello World from Java Spring Boot!");
        response.put("status", "Success");
        response.put("time", LocalDateTime.now());
        return response;
    }
}


