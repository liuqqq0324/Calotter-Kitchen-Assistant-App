package com.calotter.integration;

import com.calotter.user.controller.dto.LoginRequest;
import com.calotter.user.controller.dto.RegisterRequest;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 用户注册和登录流程集成测试
 * 
 * 测试完整的用户注册和登录流程，包括：
 * - 用户注册
 * - 用户登录
 * - JWT Token生成和验证
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class UserRegistrationAndLoginIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    private RegisterRequest registerRequest;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        userRepository.deleteAll();

        registerRequest = new RegisterRequest();
        registerRequest.setUsername("testuser");
        registerRequest.setPassword("password123");
        registerRequest.setEmail("test@example.com");
    }

    @Test
    void testUserRegistrationAndLoginFlow() throws Exception {
        // ==================== 步骤1：用户注册 ====================
        String registerResponse = mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").exists())
                .andExpect(jsonPath("$.data.userId").exists())
                .andExpect(jsonPath("$.data.username").value("testuser"))
                .andExpect(jsonPath("$.data.email").value("test@example.com"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        // 验证用户已保存到数据库
        User savedUser = userRepository.findByUsername("testuser").orElse(null);
        assertThat(savedUser).isNotNull();
        assertThat(savedUser.getEmail()).isEqualTo("test@example.com");
        assertThat(savedUser.getStatus()).isEqualTo(1); // 1: 可用
        assertThat(savedUser.getIsOnboarded()).isFalse();

        // ==================== 步骤2：用户登录（使用用户名） ====================
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsernameOrEmail("testuser");
        loginRequest.setPassword("password123");

        mockMvc.perform(post("/api/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").exists())
                .andExpect(jsonPath("$.data.userId").value(savedUser.getId()))
                .andExpect(jsonPath("$.data.username").value("testuser"));

        // ==================== 步骤3：用户登录（使用邮箱） ====================
        loginRequest.setUsernameOrEmail("test@example.com");

        mockMvc.perform(post("/api/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").exists());
    }

    @Test
    void testUserRegistration_DuplicateUsername() throws Exception {
        // Given: 先注册一个用户
        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk());

        // When & Then: 尝试用相同的用户名注册
        RegisterRequest duplicateRequest = new RegisterRequest();
        duplicateRequest.setUsername("testuser");
        duplicateRequest.setPassword("password456");
        duplicateRequest.setEmail("another@example.com");

        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(duplicateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("用户名已存在")));
    }

    @Test
    void testUserRegistration_DuplicateEmail() throws Exception {
        // Given: 先注册一个用户
        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk());

        // When & Then: 尝试用相同的邮箱注册
        RegisterRequest duplicateRequest = new RegisterRequest();
        duplicateRequest.setUsername("anotheruser");
        duplicateRequest.setPassword("password456");
        duplicateRequest.setEmail("test@example.com");

        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(duplicateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("邮箱已被注册")));
    }

    @Test
    void testUserLogin_WrongPassword() throws Exception {
        // Given: 先注册一个用户
        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk());

        // When & Then: 使用错误的密码登录
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsernameOrEmail("testuser");
        loginRequest.setPassword("wrongpassword");

        mockMvc.perform(post("/api/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("用户名或密码错误")));
    }

    @Test
    void testUserLogin_UserNotFound() throws Exception {
        // When & Then: 尝试登录不存在的用户
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsernameOrEmail("nonexistent");
        loginRequest.setPassword("password123");

        mockMvc.perform(post("/api/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("用户名或密码错误")));
    }
}

