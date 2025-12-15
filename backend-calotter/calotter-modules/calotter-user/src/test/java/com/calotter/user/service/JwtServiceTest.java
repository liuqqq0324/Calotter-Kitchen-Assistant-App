package com.calotter.user.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.test.util.ReflectionTestUtils;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Date;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * JwtService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class JwtServiceTest {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        
        // 使用反射设置私有字段（模拟 @Value 注入）
        ReflectionTestUtils.setField(jwtService, "secretKey", "testSecretKeyForJwtTokenGenerationAndValidation123456");
        ReflectionTestUtils.setField(jwtService, "issuer", "calotter-test");
        ReflectionTestUtils.setField(jwtService, "audience", "calotter-app");
        ReflectionTestUtils.setField(jwtService, "expiration", 3600L); // 1小时
    }

    @Test
    void testGenerateToken_Success() {
        // Given
        Long userId = 1L;
        String username = "testuser";

        // When
        String token = jwtService.generateToken(userId, username);

        // Then
        assertThat(token).isNotNull();
        assertThat(token).isNotEmpty();
        // Token 应该包含三个部分（header.payload.signature），用点分隔
        assertThat(token.split("\\.")).hasSize(3);
    }

    @Test
    void testExtractUsername_Success() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        String extractedUsername = jwtService.extractUsername(token);

        // Then
        assertThat(extractedUsername).isEqualTo(username);
    }

    @Test
    void testExtractUserId_Success() {
        // Given
        Long userId = 123L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        Long extractedUserId = jwtService.extractUserId(token);

        // Then
        assertThat(extractedUserId).isEqualTo(userId);
    }

    @Test
    void testExtractExpiration_Success() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        Date expiration = jwtService.extractExpiration(token);

        // Then
        assertThat(expiration).isNotNull();
        // 过期时间应该在未来（在当前时间之后，但在1小时后）
        Date now = new Date();
        Date oneHourLater = new Date(now.getTime() + TimeUnit.HOURS.toMillis(2));
        assertThat(expiration).isAfter(now);
        assertThat(expiration).isBefore(oneHourLater);
    }

    @Test
    void testValidateToken_ValidToken() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        Boolean isValid = jwtService.validateToken(token);

        // Then
        assertThat(isValid).isTrue();
    }

    @Test
    void testValidateToken_InvalidToken() {
        // Given
        String invalidToken = "invalid.token.string";

        // When
        Boolean isValid = jwtService.validateToken(invalidToken);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    void testValidateToken_EmptyToken() {
        // Given
        String emptyToken = "";

        // When
        Boolean isValid = jwtService.validateToken(emptyToken);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    void testValidateToken_NullToken() {
        // Given
        String nullToken = null;

        // When - validateToken 对 null 应该返回 false（内部捕获异常）
        // 注意：由于 validateToken 内部捕获所有异常，null 会导致 NullPointerException，被捕获后返回 false
        // 但在某些 JWT 库实现中，null 可能直接导致异常，这个测试主要验证异常处理逻辑
        // 实际行为取决于 JWT 库的实现，这里主要确保方法不会崩溃
        Boolean result = jwtService.validateToken(nullToken);
        
        // Then - 应该返回 false（异常被捕获）
        assertThat(result).isFalse();
    }

    @Test
    void testIsTokenExpired_NotExpired() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        Boolean isExpired = jwtService.isTokenExpired(token);

        // Then
        assertThat(isExpired).isFalse();
    }

    @Test
    void testTokenContainsCorrectClaims() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        String extractedUsername = jwtService.extractUsername(token);
        Long extractedUserId = jwtService.extractUserId(token);

        // Then
        assertThat(extractedUsername).isEqualTo(username);
        assertThat(extractedUserId).isEqualTo(userId);
    }

    @Test
    void testGenerateMultipleTokens_Unique() {
        // Given
        Long userId1 = 1L;
        String username1 = "user1";
        Long userId2 = 2L;
        String username2 = "user2";

        // When
        String token1 = jwtService.generateToken(userId1, username1);
        String token2 = jwtService.generateToken(userId2, username2);

        // Then - 即使相同用户，每次生成的token也应该不同（因为issuedAt不同）
        assertThat(token1).isNotEqualTo(token2);
    }

    @Test
    void testTokenExpirationTime_NotExpired() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When - 立即检查，应该未过期
        Boolean isExpired = jwtService.isTokenExpired(token);

        // Then
        assertThat(isExpired).isFalse();
    }
}
