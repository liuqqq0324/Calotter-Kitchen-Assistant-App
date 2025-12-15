package com.souschef.controller;

import com.souschef.dto.user.*;
import com.souschef.entity.User;
import com.souschef.entity.UserAllergy;
import com.souschef.entity.UserPreference;
import com.souschef.entity.UserTaboo;
import com.souschef.repository.UserAllergyRepository;
import com.souschef.repository.UserPreferenceRepository;
import com.souschef.repository.UserRepository;
import com.souschef.repository.UserTabooRepository;
import com.souschef.service.JwtService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/ums/user")
@CrossOrigin(origins = "*")
public class UserController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserPreferenceRepository userPreferenceRepository;
    
    @Autowired
    private UserTabooRepository userTabooRepository;
    
    @Autowired
    private UserAllergyRepository userAllergyRepository;
    
    @Autowired
    private JwtService jwtService;
    
    private Long getCurrentUserId(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            return jwtService.extractUserId(token);
        }
        return null;
    }
    
    @GetMapping
    public ResponseEntity<?> getUserBriefInfo(
            @RequestParam(required = false) Long id,
            HttpServletRequest request) {
        Long userId = id != null ? id : getCurrentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse("User not found"));
        }
        
        User user = userOpt.get();
        UserBriefInfoResponse response = new UserBriefInfoResponse();
        response.setUserId(user.getUserId());
        response.setUserName(user.getUsername());
        response.setEmail(user.getEmail());
        
        UserBriefInfoResponse.UserProfile profile = new UserBriefInfoResponse.UserProfile();
        profile.setAge(user.getAge());
        profile.setGender(user.getGender());
        profile.setHeight(user.getHeight());
        profile.setWeight(user.getWeight());
        response.setProfile(profile);
        
        return ResponseEntity.ok(response);
    }
    
    @PutMapping
    public ResponseEntity<?> updateUserInfo(
            @RequestParam(required = false) Long id,
            @RequestBody UserBriefInfoResponse request,
            HttpServletRequest httpRequest) {
        Long userId = id != null ? id : getCurrentUserId(httpRequest);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse("User not found"));
        }
        
        User user = userOpt.get();
        if (request.getProfile() != null) {
            user.setAge(request.getProfile().getAge());
            user.setGender(request.getProfile().getGender());
            user.setHeight(request.getProfile().getHeight());
            user.setWeight(request.getProfile().getWeight());
        }
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        
        return ResponseEntity.ok(new SuccessResponse(user.getUserId(), "User info updated successfully"));
    }
    
    @GetMapping("/preferences")
    public ResponseEntity<?> getUserPreferences(
            @RequestParam(required = false) Long id,
            HttpServletRequest request) {
        Long userId = id != null ? id : getCurrentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        List<UserPreference> preferences = userPreferenceRepository.findByUserId(userId);
        UserPreferencesResponse response = new UserPreferencesResponse();
        response.setUserId(userId);
        
        for (UserPreference pref : preferences) {
            switch (pref.getPreferenceType()) {
                case "dietaryType":
                    response.getPreferences().setDietaryType(pref.getPreferenceValue());
                    break;
                case "cuisineTypes":
                    response.getPreferences().getCuisineTypes().add(pref.getPreferenceValue());
                    break;
                case "spiceLevel":
                    response.getPreferences().setSpiceLevel(pref.getPreferenceValue());
                    break;
                case "cookingTimePreference":
                    response.getPreferences().setCookingTimePreference(pref.getPreferenceValue());
                    break;
            }
        }
        
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/preferences")
    public ResponseEntity<?> updateUserPreferences(
            @RequestParam(required = false) Long id,
            @RequestBody UserPreferencesResponse.UserPreferences request,
            HttpServletRequest httpRequest) {
        Long userId = id != null ? id : getCurrentUserId(httpRequest);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        // Remove existing preferences
        userPreferenceRepository.deleteByUserId(userId);
        
        // Add new preferences
        if (request.getDietaryType() != null && !request.getDietaryType().isEmpty()) {
            UserPreference pref = new UserPreference();
            pref.setUserId(userId);
            pref.setPreferenceType("dietaryType");
            pref.setPreferenceValue(request.getDietaryType());
            userPreferenceRepository.save(pref);
        }
        
        if (request.getSpiceLevel() != null && !request.getSpiceLevel().isEmpty()) {
            UserPreference pref = new UserPreference();
            pref.setUserId(userId);
            pref.setPreferenceType("spiceLevel");
            pref.setPreferenceValue(request.getSpiceLevel());
            userPreferenceRepository.save(pref);
        }
        
        if (request.getCookingTimePreference() != null && !request.getCookingTimePreference().isEmpty()) {
            UserPreference pref = new UserPreference();
            pref.setUserId(userId);
            pref.setPreferenceType("cookingTimePreference");
            pref.setPreferenceValue(request.getCookingTimePreference());
            userPreferenceRepository.save(pref);
        }
        
        for (String cuisine : request.getCuisineTypes()) {
            UserPreference pref = new UserPreference();
            pref.setUserId(userId);
            pref.setPreferenceType("cuisineTypes");
            pref.setPreferenceValue(cuisine);
            userPreferenceRepository.save(pref);
        }
        
        return ResponseEntity.ok(new SuccessResponse(userId, "User preferences updated successfully"));
    }
    
    @GetMapping("/taboos")
    public ResponseEntity<?> getUserTaboos(
            @RequestParam(required = false) Long id,
            HttpServletRequest request) {
        Long userId = id != null ? id : getCurrentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        List<UserTaboo> taboos = userTabooRepository.findByUserId(userId);
        UserTaboosResponse response = new UserTaboosResponse();
        response.setUserId(userId);
        response.setTaboos(taboos.stream().map(UserTaboo::getTaboo).toList());
        
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/taboos")
    public ResponseEntity<?> updateUserTaboos(
            @RequestParam(required = false) Long id,
            @RequestBody UserTaboosResponse request,
            HttpServletRequest httpRequest) {
        Long userId = id != null ? id : getCurrentUserId(httpRequest);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        // Remove existing taboos
        userTabooRepository.deleteByUserId(userId);
        
        // Add new taboos
        for (String taboo : request.getTaboos()) {
            UserTaboo userTaboo = new UserTaboo();
            userTaboo.setUserId(userId);
            userTaboo.setTaboo(taboo);
            userTabooRepository.save(userTaboo);
        }
        
        return ResponseEntity.ok(new SuccessResponse(userId, "User taboos updated successfully"));
    }
    
    @GetMapping("/allergies")
    public ResponseEntity<?> getUserAllergies(
            @RequestParam(required = false) Long id,
            HttpServletRequest request) {
        Long userId = id != null ? id : getCurrentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        List<UserAllergy> allergies = userAllergyRepository.findByUserId(userId);
        UserAllergiesResponse response = new UserAllergiesResponse();
        response.setUserId(userId);
        response.setAllergies(allergies.stream().map(UserAllergy::getAllergy).toList());
        
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/allergies")
    public ResponseEntity<?> updateUserAllergies(
            @RequestParam(required = false) Long id,
            @RequestBody UserAllergiesResponse request,
            HttpServletRequest httpRequest) {
        Long userId = id != null ? id : getCurrentUserId(httpRequest);
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        // Remove existing allergies
        userAllergyRepository.deleteByUserId(userId);
        
        // Add new allergies
        for (String allergy : request.getAllergies()) {
            UserAllergy userAllergy = new UserAllergy();
            userAllergy.setUserId(userId);
            userAllergy.setAllergy(allergy);
            userAllergyRepository.save(userAllergy);
        }
        
        return ResponseEntity.ok(new SuccessResponse(userId, "User allergies updated successfully"));
    }
    
    private static class ErrorResponse {
        private String message;
        
        public ErrorResponse(String message) {
            this.message = message;
        }
        
        public String getMessage() {
            return message;
        }
    }
    
    private static class SuccessResponse {
        private Long userId;
        private String message;
        
        public SuccessResponse(Long userId, String message) {
            this.userId = userId;
            this.message = message;
        }
        
        public Long getUserId() {
            return userId;
        }
        
        public String getMessage() {
            return message;
        }
    }
}


