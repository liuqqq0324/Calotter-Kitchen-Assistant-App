package com.calotter.user.service;

import com.calotter.user.controller.dto.AuthResponse;
import com.calotter.user.controller.dto.LoginRequest;
import com.calotter.user.controller.dto.RegisterRequest;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 用户服务
 */
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    
    /**
     * 用户注册
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // 检查用户名是否已存在
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("用户名已存在");
        }
        
        // 检查邮箱是否已存在
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("邮箱已被注册");
        }
        
        // 创建新用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setRole("ROLE_USER");
        user.setStatus(1); // 1: 可用
        user.setIsOnboarded(false);
        
        // 保存用户
        user = userRepository.save(user);
        
        // 生成 JWT Token
        String token = jwtService.generateToken(user.getId(), user.getUsername());
        
        // 返回认证响应
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .build();
    }
    
    /**
     * 用户登录
     */
    public AuthResponse login(LoginRequest request) {
        // 查找用户（支持用户名或邮箱登录）
        User user = userRepository.findByUsername(request.getUsernameOrEmail())
                .orElseGet(() -> userRepository.findByEmail(request.getUsernameOrEmail())
                        .orElseThrow(() -> new IllegalArgumentException("用户名或密码错误")));
        
        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("用户名或密码错误");
        }
        
        // 检查用户状态
        if (user.getStatus() == 0) {
            throw new IllegalArgumentException("账户未激活，请联系管理员");
        }
        if (user.getStatus() == 2) {
            throw new IllegalArgumentException("账户已被封禁，请联系管理员");
        }
        
        // 生成 JWT Token
        String token = jwtService.generateToken(user.getId(), user.getUsername());
        
        // 返回认证响应
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .build();
    }
}
