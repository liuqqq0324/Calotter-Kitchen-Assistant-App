package com.souschef.dto.user;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class UserPreferencesResponse {
    private Long userId;
    private UserPreferences preferences = new UserPreferences();
    
    @Data
    public static class UserPreferences {
        private String dietaryType;
        private List<String> cuisineTypes = new ArrayList<>();
        private String spiceLevel;
        private String cookingTimePreference;
    }
}


