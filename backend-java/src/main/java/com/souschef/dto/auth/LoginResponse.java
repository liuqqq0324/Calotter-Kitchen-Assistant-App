package com.souschef.dto.auth;

import lombok.Data;

@Data
public class LoginResponse {
    private Long userId;
    private Integer kitchenId;
    private TokenInfo token;
    
    @Data
    public static class TokenInfo {
        private String accessToken;
        private Integer expiresIn = 3600;
    }
}

