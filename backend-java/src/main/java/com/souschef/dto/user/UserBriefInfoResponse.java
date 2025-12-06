package com.souschef.dto.user;

import lombok.Data;

@Data
public class UserBriefInfoResponse {
    private Long userId;
    private String userName;
    private String email;
    private UserProfile profile;
    
    @Data
    public static class UserProfile {
        private Integer age;
        private Integer height;
        private Integer weight;
    }
}

