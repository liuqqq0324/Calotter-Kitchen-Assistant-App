package com.calotter.user.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.test.util.ReflectionTestUtils;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Date;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * JwtService 完整单元测试
 * 覆盖所有JWT相关功能：生成、提取、验证Token
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("JWT服务测试")
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
    @DisplayName("生成Token - 成功")
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
    @DisplayName("生成Token - 不同用户生成不同Token")
    void testGenerateToken_DifferentUsers() {
        // Given
        Long userId1 = 1L;
        String username1 = "user1";
        Long userId2 = 2L;
        String username2 = "user2";

        // When
        String token1 = jwtService.generateToken(userId1, username1);
        String token2 = jwtService.generateToken(userId2, username2);

        // Then
        assertThat(token1).isNotEqualTo(token2);
    }

    @Test
    @DisplayName("提取用户名 - 成功")
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
    @DisplayName("提取用户ID - 成功")
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
    @DisplayName("提取过期时间 - 成功")
    void testExtractExpiration_Success() {
        // Given
        Long userId = 1L;
        String username = "testuser";
        String token = jwtService.generateToken(userId, username);

        // When
        Date expiration = jwtService.extractExpiration(token);

        // Then
        assertThat(expiration).isNotNull();
        // 过期时间应该在未来（在当前时间之后，但在2小时后）
        Date now = new Date();
        Date twoHoursLater = new Date(now.getTime() + TimeUnit.HOURS.toMillis(2));
        assertThat(expiration).isAfter(now);
        assertThat(expiration).isBefore(twoHoursLater);
    }

    @Test
    @DisplayName("验证Token - 有效Token")
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
    @DisplayName("验证Token - 无效Token格式")
    void testValidateToken_InvalidToken() {
        // Given
        String invalidToken = "invalid.token.string";

        // When
        Boolean isValid = jwtService.validateToken(invalidToken);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    @DisplayName("验证Token - 空字符串")
    void testValidateToken_EmptyToken() {
        // Given
        String emptyToken = "";

        // When
        Boolean isValid = jwtService.validateToken(emptyToken);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    @DisplayName("验证Token - null值")
    void testValidateToken_NullToken() {
        // Given
        String nullToken = null;

        // When
        Boolean result = jwtService.validateToken(nullToken);
        
        // Then - 应该返回 false（异常被捕获）
        assertThat(result).isFalse();
    }

    @Test
    @DisplayName("验证Token过期 - 未过期")
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
    @DisplayName("Token包含正确的Claims")
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
    @DisplayName("生成多个Token - 唯一性")
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
    @DisplayName("相同用户多次生成Token - 唯一性")
    void testGenerateMultipleTokens_SameUser_Unique() {
        // Given
        Long userId = 1L;
        String username = "testuser";

        // When
        String token1 = jwtService.generateToken(userId, username);
        // 等待一小段时间确保时间戳不同
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        String token2 = jwtService.generateToken(userId, username);

        // Then - 由于issuedAt不同，token应该不同
        assertThat(token1).isNotEqualTo(token2);
    }

    @Test
    @DisplayName("Token过期时间 - 未过期")
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

    @Test
    @DisplayName("提取Claims - 完整流程")
    void testExtractClaims_CompleteFlow() {
        // Given
        Long userId = 999L;
        String username = "testuser999";
        String token = jwtService.generateToken(userId, username);

        // When
        String extractedUsername = jwtService.extractUsername(token);
        Long extractedUserId = jwtService.extractUserId(token);
        Date expiration = jwtService.extractExpiration(token);
        Boolean isValid = jwtService.validateToken(token);
        Boolean isExpired = jwtService.isTokenExpired(token);

        // Then
        assertThat(extractedUsername).isEqualTo(username);
        assertThat(extractedUserId).isEqualTo(userId);
        assertThat(expiration).isNotNull();
        assertThat(isValid).isTrue();
        assertThat(isExpired).isFalse();
    }

    @Test
    @DisplayName("Token格式验证 - 三部分结构")
    void testTokenFormat_ThreeParts() {
        // Given
        Long userId = 1L;
        String username = "testuser";

        // When
        String token = jwtService.generateToken(userId, username);
        String[] parts = token.split("\\.");

        // Then
        assertThat(parts).hasSize(3);
        assertThat(parts[0]).isNotEmpty(); // Header
        assertThat(parts[1]).isNotEmpty(); // Payload
        assertThat(parts[2]).isNotEmpty(); // Signature
    }
}
