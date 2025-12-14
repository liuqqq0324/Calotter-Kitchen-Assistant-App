package com.calotter.user.controller;

import com.calotter.common.core.Result;
import com.calotter.user.controller.dto.AuthResponse;
import com.calotter.user.controller.dto.LoginRequest;
import com.calotter.user.controller.dto.RegisterRequest;
import com.calotter.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    /**
     * 用户注册
     * POST /api/user/register
     */
    @PostMapping("/register")
    public Result<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = userService.register(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 用户登录
     * POST /api/user/login
     */
    @PostMapping("/login")
    public Result<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = userService.login(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }
}
