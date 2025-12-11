package com.calotter.common.core.utils;

import com.calotter.common.core.exception.ServiceException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;

/**
 * Token工具类
 * 统一处理JWT Token解析和用户ID提取
 * 
 * @author Auto Generated
 */
@Slf4j
public class TokenUtils {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final int BEARER_PREFIX_LENGTH = BEARER_PREFIX.length();

    /**
     * 从Authorization header中提取token
     * 
     * @param authHeader Authorization header值，格式: "Bearer <token>"
     * @return token字符串，如果header为空或格式不正确则返回null
     */
    public static String extractToken(String authHeader) {
        if (!StringUtils.hasText(authHeader)) {
            return null;
        }

        if (authHeader.startsWith(BEARER_PREFIX)) {
            String token = authHeader.substring(BEARER_PREFIX_LENGTH).trim();
            if (StringUtils.hasText(token)) {
                return token;
            }
        }

        // 如果没有Bearer前缀，尝试直接使用整个字符串作为token
        // 这可以兼容某些客户端可能不发送Bearer前缀的情况
        String trimmed = authHeader.trim();
        if (StringUtils.hasText(trimmed)) {
            log.warn("Token without Bearer prefix detected: {}", trimmed.substring(0, Math.min(10, trimmed.length())));
            return trimmed;
        }

        return null;
    }

    /**
     * 从Authorization header中提取用户ID
     * 
     * 注意：当前系统使用UUID token，需要通过外部服务验证token并获取userId
     * 未来如果迁移到JWT，可以直接从token中解析userId
     * 
     * 实现策略：
     * 1. 如果token是JWT格式，尝试解析JWT获取userId（未来实现）
     * 2. 如果token是UUID格式，从token缓存/存储中获取userId映射
     * 3. 如果无法获取，返回null由调用方处理
     * 
     * @param authHeader Authorization header值
     * @return 用户ID，如果token无效或无法解析则返回null
     */
    public static Long extractUserIdFromToken(String authHeader) {
        String token = extractToken(authHeader);
        if (token == null) {
            log.debug("No token found in Authorization header");
            return null;
        }

        // 检查token格式
        if (!isValidTokenFormat(token)) {
            log.warn("Invalid token format: {}", token.length() > 20 ? token.substring(0, 20) + "..." : token);
            return null;
        }

        // 方案1: 如果是JWT格式，尝试解析（未来实现）
        if (isJwtFormat(token)) {
            // TODO: 实现JWT解析逻辑
            // 可以使用JWT库（如io.jsonwebtoken）解析token并提取userId
            log.debug("JWT token detected, but JWT parsing not yet implemented");
            return null;
        }

        // 方案2: 如果是UUID格式，从缓存/存储中获取userId映射
        if (isUuidFormat(token)) {
            // TODO: 实现UUID token验证逻辑
            // 方案A: 从Redis缓存中获取 token -> userId 映射
            // 方案B: 通过Feign调用calotter-user服务验证token
            // 方案C: 从数据库token表中查询
            
            // 临时实现：使用简单的内存缓存（仅用于开发测试）
            // 注意：这是临时方案，生产环境需要实现真正的token验证机制
            Long userId = TokenCache.getUserId(token);
            if (userId != null) {
                log.debug("Found userId from token cache: {}", userId);
                return userId;
            }
            
            // 如果缓存中没有，记录警告但暂时返回null
            // 开发阶段可以通过其他方式（如请求参数）传递userId
            log.warn("Token not found in cache. Token: {}. " +
                    "For development: consider using request parameter to pass userId, " +
                    "or implement proper token validation.", 
                    token.length() > 10 ? token.substring(0, 10) + "..." : token);
            return null;
        }

        // 其他格式的token
        log.warn("Unknown token format: {}", token.length() > 20 ? token.substring(0, 20) + "..." : token);
        return null;
    }

    /**
     * 从Authorization header中提取用户ID（带异常抛出）
     * 
     * @param authHeader Authorization header值
     * @return 用户ID
     * @throws ServiceException 如果token无效或无法解析
     */
    public static Long extractUserIdOrThrow(String authHeader) {
        Long userId = extractUserIdFromToken(authHeader);
        if (userId == null) {
            throw new ServiceException("Unauthorized: Invalid or missing token");
        }
        return userId;
    }

    /**
     * 验证token格式是否有效
     * 
     * @param token token字符串
     * @return true如果token格式看起来有效，false否则
     */
    public static boolean isValidTokenFormat(String token) {
        if (!StringUtils.hasText(token)) {
            return false;
        }
        
        // 基本格式检查：token应该有一定长度
        // UUID格式: 32个字符（无连字符）或36个字符（有连字符）
        // JWT格式: 三个部分用.分隔
        if (token.length() < 10) {
            return false;
        }
        
        // 检查是否是JWT格式（包含两个点）
        if (token.contains(".") && token.split("\\.").length == 3) {
            return true;
        }
        
        // 检查是否是UUID格式（32或36字符）
        if (token.length() == 32 || token.length() == 36) {
            return true;
        }
        
        return true; // 其他格式也接受，由验证逻辑决定
    }

    /**
     * 判断token是否是JWT格式
     * 
     * @param token token字符串
     * @return true如果是JWT格式
     */
    public static boolean isJwtFormat(String token) {
        if (!StringUtils.hasText(token)) {
            return false;
        }
        String[] parts = token.split("\\.");
        return parts.length == 3;
    }

    /**
     * 判断token是否是UUID格式
     * 
     * @param token token字符串
     * @return true如果是UUID格式
     */
    public static boolean isUuidFormat(String token) {
        if (!StringUtils.hasText(token)) {
            return false;
        }
        // UUID格式: 32字符（无连字符）或36字符（有连字符）
        String cleaned = token.replace("-", "");
        return cleaned.length() == 32 && cleaned.matches("[0-9a-fA-F]{32}");
    }

    /**
     * 临时Token缓存（仅用于开发测试）
     * 生产环境应该使用Redis或数据库存储token映射
     */
    private static class TokenCache {
        // 简单的内存Map存储 token -> userId 映射
        // 注意：这是临时方案，重启后数据会丢失
        private static final java.util.Map<String, Long> cache = new java.util.concurrent.ConcurrentHashMap<>();

        /**
         * 存储token到userId的映射
         * 应该在用户登录时调用此方法
         * 
         * @param token token字符串
         * @param userId 用户ID
         */
        public static void putToken(String token, Long userId) {
            cache.put(token, userId);
            log.debug("Token cached: {} -> {}", token.length() > 10 ? token.substring(0, 10) + "..." : token, userId);
        }

        /**
         * 从缓存中获取userId
         * 
         * @param token token字符串
         * @return 用户ID，如果不存在则返回null
         */
        public static Long getUserId(String token) {
            return cache.get(token);
        }

        /**
         * 移除token（用于登出）
         * 
         * @param token token字符串
         */
        public static void removeToken(String token) {
            cache.remove(token);
            log.debug("Token removed from cache: {}", token.length() > 10 ? token.substring(0, 10) + "..." : token);
        }

        /**
         * 清空所有token（用于测试）
         */
        public static void clear() {
            cache.clear();
            log.debug("Token cache cleared");
        }
    }

    /**
     * 存储token到userId的映射（临时方案，仅用于开发测试）
     * 应该在用户登录成功后调用此方法
     * 
     * @param token token字符串
     * @param userId 用户ID
     */
    public static void cacheToken(String token, Long userId) {
        TokenCache.putToken(token, userId);
    }

    /**
     * 移除token（用于登出）
     * 
     * @param token token字符串
     */
    public static void removeToken(String token) {
        TokenCache.removeToken(token);
    }
}

