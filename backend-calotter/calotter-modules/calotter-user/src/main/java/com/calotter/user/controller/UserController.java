package com.calotter.user.controller;

import com.calotter.common.core.Result;
import com.calotter.user.controller.dto.AuthResponse;
import com.calotter.user.controller.dto.LoginRequest;
import com.calotter.user.controller.dto.RegisterRequest;
import com.calotter.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import com.calotter.user.service.JwtService;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    private final JwtService jwtService;
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


    /**
     * 用户登出
     * POST /api/user/logout
     * 注意：JWT 是无状态的，这里主要验证 token 有效性并返回成功
     * 前端负责删除本地存储的 token
     */
    @PostMapping("/logout")
    public Result<String> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            // 提取 token
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                // 即使没有 token，也返回成功（前端可能已经删除了）
                return Result.success("Logged out successfully");
            }
            
            String token = authHeader.substring(7); // 移除 "Bearer " 前缀
            
            // 验证 token 是否有效（可选，主要用于日志记录）
            if (jwtService.validateToken(token)) {
                // Token 有效，可以在这里记录日志或执行其他操作
                // 注意：JWT 无法主动失效，除非使用黑名单机制
            }
            
            // 返回成功响应
            return Result.success("Logged out successfully");
        } catch (Exception e) {
            // 即使出错也返回成功，确保前端可以清理本地存储
            return Result.success("Logged out (local storage cleared)");
        }
    }
}
