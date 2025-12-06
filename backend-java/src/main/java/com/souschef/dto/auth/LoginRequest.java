package com.souschef.dto.auth;

import lombok.Data;

@Data
public class LoginRequest {
    private String identifier; // Username or Email
    private String password;
}

