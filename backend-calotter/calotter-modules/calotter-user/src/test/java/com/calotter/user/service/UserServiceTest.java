package com.calotter.user.service;

import com.calotter.user.controller.dto.AuthResponse;
import com.calotter.user.controller.dto.LoginRequest;
import com.calotter.user.controller.dto.RegisterRequest;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * UserService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private UserService userService;

    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;
    private User user;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest();
        registerRequest.setUsername("testuser");
        registerRequest.setPassword("password123");
        registerRequest.setEmail("test@example.com");

        loginRequest = new LoginRequest();
        loginRequest.setUsernameOrEmail("testuser");
        loginRequest.setPassword("password123");

        user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("$2a$10$encodedPasswordHash");
        user.setRole("ROLE_USER");
        user.setStatus(1); // 1: 可用
        user.setIsOnboarded(false);
    }

    // ==================== 注册测试 ====================

    @Test
    void testRegister_Success() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("$2a$10$encodedPasswordHash");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });
        when(jwtService.generateToken(1L, "testuser")).thenReturn("test-token");

        // When
        AuthResponse response = userService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("test-token");
        assertThat(response.getUserId()).isEqualTo(1L);
        assertThat(response.getUsername()).isEqualTo("testuser");
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getRole()).isEqualTo("ROLE_USER");

        // 验证保存的用户信息
        verify(userRepository, times(1)).save(argThat(u ->
                u.getUsername().equals("testuser") &&
                u.getEmail().equals("test@example.com") &&
                u.getRole().equals("ROLE_USER") &&
                u.getStatus() == 1 &&
                !u.getIsOnboarded()
        ));
        verify(passwordEncoder, times(1)).encode("password123");
        verify(jwtService, times(1)).generateToken(1L, "testuser");
    }

    @Test
    void testRegister_UsernameAlreadyExists() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.register(registerRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户名已存在");

        verify(userRepository, never()).save(any());
        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    void testRegister_EmailAlreadyExists() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.register(registerRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("邮箱已被注册");

        verify(userRepository, never()).save(any());
        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    void testRegister_PasswordEncoded() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("$2a$10$encodedPasswordHash");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });
        when(jwtService.generateToken(any(), any())).thenReturn("test-token");

        // When
        userService.register(registerRequest);

        // Then - 验证密码被加密
        verify(passwordEncoder, times(1)).encode("password123");
        verify(userRepository, times(1)).save(argThat(u ->
                u.getPasswordHash().equals("$2a$10$encodedPasswordHash")
        ));
    }

    // ==================== 登录测试 ====================

    @Test
    void testLogin_WithUsername_Success() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);
        when(jwtService.generateToken(1L, "testuser")).thenReturn("test-token");

        // When
        AuthResponse response = userService.login(loginRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("test-token");
        assertThat(response.getUserId()).isEqualTo(1L);
        assertThat(response.getUsername()).isEqualTo("testuser");
        assertThat(response.getEmail()).isEqualTo("test@example.com");

        verify(userRepository, times(1)).findByUsername("testuser");
        verify(userRepository, never()).findByEmail(anyString());
        verify(passwordEncoder, times(1)).matches("password123", user.getPasswordHash());
        verify(jwtService, times(1)).generateToken(1L, "testuser");
    }

    @Test
    void testLogin_WithEmail_Success() {
        // Given
        loginRequest.setUsernameOrEmail("test@example.com");
        when(userRepository.findByUsername("test@example.com")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);
        when(jwtService.generateToken(1L, "testuser")).thenReturn("test-token");

        // When
        AuthResponse response = userService.login(loginRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("test-token");
        assertThat(response.getUserId()).isEqualTo(1L);

        verify(userRepository, times(1)).findByUsername("test@example.com");
        verify(userRepository, times(1)).findByEmail("test@example.com");
        verify(passwordEncoder, times(1)).matches("password123", user.getPasswordHash());
    }

    @Test
    void testLogin_UserNotFound() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("testuser")).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户名或密码错误");

        verify(passwordEncoder, never()).matches(anyString(), anyString());
        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    void testLogin_WrongPassword() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrongpassword", user.getPasswordHash())).thenReturn(false);

        loginRequest.setPassword("wrongpassword");

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户名或密码错误");

        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    void testLogin_AccountNotActivated() {
        // Given
        user.setStatus(0); // 0: 未激活
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("账户未激活");

        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    void testLogin_AccountBanned() {
        // Given
        user.setStatus(2); // 2: 封禁
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("账户已被封禁");

        verify(jwtService, never()).generateToken(any(), any());
    }
}
