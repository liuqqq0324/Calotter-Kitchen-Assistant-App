package com.souschef.controller;

import com.souschef.dto.auth.LoginRequest;
import com.souschef.dto.auth.LoginResponse;
import com.souschef.dto.auth.RegisterRequest;
import com.souschef.dto.auth.RegisterResponse;
import com.souschef.entity.Kitchen;
import com.souschef.entity.User;
import com.souschef.repository.KitchenRepository;
import com.souschef.repository.UserRepository;
import com.souschef.service.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Optional;

@RestController
@RequestMapping("/api/ums/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private KitchenRepository kitchenRepository;
    
    @Autowired
    private JwtService jwtService;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty() ||
            request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("Username and password required"));
        }
        
        if (userRepository.existsByUsername(request.getUsername())) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(new ErrorResponse("Username exists"));
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        // 先保存用户
        user = userRepository.save(user);
        
        // 注册即送厨房
        Kitchen kitchen = new Kitchen();
        kitchen.setUserId(user.getUserId());
        kitchen = kitchenRepository.save(kitchen);
        user.setKitchen(kitchen);
        userRepository.save(user);
        
        RegisterResponse response = new RegisterResponse();
        response.setUserId(user.getUserId());
        response.setMessage("Registered successfully");
        
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        Optional<User> userOpt = userRepository.findByUsernameOrEmail(
                request.getIdentifier(), request.getIdentifier());
        
        if (userOpt.isEmpty() || 
            !passwordEncoder.matches(request.getPassword(), userOpt.get().getPasswordHash())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse("Invalid credentials"));
        }
        
        User user = userOpt.get();
        
        // 厨房自愈 (如果老数据没厨房，现场造一个)
        Integer kitchenId;
        if (user.getKitchen() == null) {
            Kitchen newKitchen = new Kitchen();
            newKitchen.setUserId(user.getUserId());
            newKitchen = kitchenRepository.save(newKitchen);
            kitchenId = newKitchen.getId();
        } else {
            kitchenId = user.getKitchen().getId();
        }
        
        // 生成 Token
        String token = jwtService.generateToken(user.getUserId(), user.getUsername());
        
        LoginResponse response = new LoginResponse();
        response.setUserId(user.getUserId());
        response.setKitchenId(kitchenId);
        LoginResponse.TokenInfo tokenInfo = new LoginResponse.TokenInfo();
        tokenInfo.setAccessToken(token);
        tokenInfo.setExpiresIn(3600);
        response.setToken(tokenInfo);
        
        return ResponseEntity.ok(response);
    }
    
    private static class ErrorResponse {
        private String message;
        
        public ErrorResponse(String message) {
            this.message = message;
        }
        
        public String getMessage() {
            return message;
        }
    }
}

