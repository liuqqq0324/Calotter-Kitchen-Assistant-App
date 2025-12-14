package com.calotter.user.api;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.calotter.user.domain.*;
import com.calotter.user.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * UMS simple API to satisfy documentation formats (success path only).
 * Paths under /api/ums/* return plain JSON DTOs as specified.
 */
@RestController
@RequestMapping("/api/ums")
@RequiredArgsConstructor
public class UmsApiController {

    private final UserMapper userMapper;
    private final UserRoleMapper userRoleMapper;
    private final PreferenceMapper preferenceMapper;
    private final RolePreferenceMapper rolePreferenceMapper;
    private final RestrictionMapper restrictionMapper;
    private final RoleRestrictionMapper roleRestrictionMapper;

    // ==== Auth ====
    @PostMapping("/auth/register")
    public ResponseEntity<RegisterResponse> register(@RequestBody RegisterRequest req) {
        try {
            // Validate request
            if (req.username == null || req.username.trim().isEmpty()) {
                RegisterResponse errorResp = new RegisterResponse();
                errorResp.userId = 0;
                errorResp.message = "Username is required";
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResp);
            }
            if (req.email == null || req.email.trim().isEmpty()) {
                RegisterResponse errorResp = new RegisterResponse();
                errorResp.userId = 0;
                errorResp.message = "Email is required";
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResp);
            }
            if (req.password == null || req.password.trim().isEmpty()) {
                RegisterResponse errorResp = new RegisterResponse();
                errorResp.userId = 0;
                errorResp.message = "Password is required";
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResp);
            }

            // Persist to ums_user via MyBatis-Plus
            User u = new User();
            u.setUsername(req.username);
            u.setEmail(req.email);
            // success-path only: store raw password into passwordHash field for now (no auth subsystem yet)
            u.setPasswordHash(req.password);
            u.setStatus((short)1);
            userMapper.insert(u);

            long userId = u.getId();

            // ensure default owner role exists for this user for linking prefs/restrictions
            getOrCreateOwnerRoleId(userId);

            // Profile fields (age, height, weight, gender) are now stored in database
            // No need to initialize them here - they will be null in DB until user sets them

            RegisterResponse resp = new RegisterResponse();
            resp.userId = userId;
            resp.message = "User registered successfully";
            return ResponseEntity.ok(resp);
        } catch (DuplicateKeyException e) {
            // Handle duplicate key exception (username or email already exists)
            String errorMessage = "Registration failed";
            String exceptionMessage = e.getMessage();
            if (exceptionMessage != null) {
                if (exceptionMessage.contains("uk_user_username") || exceptionMessage.contains("username")) {
                    errorMessage = "Username already exists";
                } else if (exceptionMessage.contains("uk_user_email") || exceptionMessage.contains("email")) {
                    errorMessage = "Email already exists";
                } else {
                    errorMessage = "User with this information already exists";
                }
            }
            RegisterResponse errorResp = new RegisterResponse();
            errorResp.userId = 0;
            errorResp.message = errorMessage;
            return ResponseEntity.status(HttpStatus.CONFLICT).body(errorResp);
        } catch (Exception e) {
            // Handle other exceptions
            RegisterResponse errorResp = new RegisterResponse();
            errorResp.userId = 0;
            errorResp.message = "Registration failed: " + e.getMessage();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResp);
        }
    }

    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest req) {
        // Find user by username or email
        LambdaQueryWrapper<User> lqw = Wrappers.lambdaQuery(User.class)
            .and(wrapper -> wrapper
                .eq(User::getUsername, req.identifier)
                .or()
            .eq(User::getEmail, req.identifier)
            )
            .last("limit 1");
        User found = userMapper.selectOne(lqw);

        // If user not found, return error
        if (found == null) {
            LoginResponse errorResp = new LoginResponse();
            errorResp.userId = 0;
            errorResp.token = null;
            errorResp.message = "Invalid username or password";
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResp);
        }

        // Verify password (currently stored as plain text, should be hashed in production)
        if (found.getPasswordHash() == null || !found.getPasswordHash().equals(req.password)) {
            LoginResponse errorResp = new LoginResponse();
            errorResp.userId = 0;
            errorResp.token = null;
            errorResp.message = "Invalid username or password";
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResp);
        }

        // Check if user account is enabled
        if (found.getStatus() == null || found.getStatus() != 1) {
            LoginResponse errorResp = new LoginResponse();
            errorResp.userId = 0;
            errorResp.token = null;
            errorResp.message = "Account is disabled";
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(errorResp);
        }

        LoginResponse resp = new LoginResponse();
        resp.userId = found.getId();
        Token tk = new Token();
        tk.accessToken = UUID.randomUUID().toString().replace("-", "");
        tk.expiresIn = 3000;
        resp.token = tk;
        
        // 临时方案：缓存token到userId的映射（仅用于开发测试）
        // 生产环境应该使用Redis或数据库存储
        com.calotter.common.core.utils.TokenUtils.cacheToken(tk.accessToken, found.getId());
        
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/auth/logout")
    public ResponseEntity<LogoutResponse> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        // 临时方案：从缓存中移除token（仅用于开发测试）
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7).trim();
            com.calotter.common.core.utils.TokenUtils.removeToken(token);
        }
        
        // In a production system, you would invalidate the token here
        // For now, we just return success since tokens are stateless
        // The frontend will clear the token from local storage
        
        LogoutResponse resp = new LogoutResponse();
        resp.message = "Logged out successfully";
        return ResponseEntity.ok(resp);
    }

    // ==== User brief ====
    @GetMapping("/user")
    public UserBrief getUser(@RequestParam("id") long id) {
        User db = userMapper.selectById(id);
        if (db != null) {
            UserBrief u = new UserBrief();
            u.userId = db.getId();
            u.userName = db.getUsername();
            u.email = db.getEmail();
            Profile p = new Profile();
            // Read profile data from database
            p.age = db.getAge();
            p.height = db.getHeight();
            p.weight = db.getWeight();
            p.gender = db.getGender();
            u.profile = p;
            return u;
        }
        return sampleUser(id);
    }

    @PutMapping("/user")
    public UpdateMessageResponse updateUser(@RequestParam("id") long id,
                                           @RequestBody UserBriefUpdateRequest req) {
        User db = userMapper.selectById(id);
        if (db == null) {
            UpdateMessageResponse errorResp = new UpdateMessageResponse();
            errorResp.userId = id;
            errorResp.message = "User not found";
            return errorResp;
        }

        // Update username if provided
        if (req.userName != null && !req.userName.trim().isEmpty()) {
            db.setUsername(req.userName);
        }
        // Update email if provided
        if (req.email != null && !req.email.trim().isEmpty()) {
            db.setEmail(req.email);
        }
        // Update profile fields if provided - persist to database
        if (req.profile != null) {
            if (req.profile.age != null) db.setAge(req.profile.age);
            if (req.profile.height != null) db.setHeight(req.profile.height);
            if (req.profile.weight != null) db.setWeight(req.profile.weight);
            if (req.profile.gender != null) db.setGender(req.profile.gender);
        }
        userMapper.updateById(db);

        UpdateMessageResponse resp = new UpdateMessageResponse();
        resp.userId = id;
        resp.message = "User info updated successfully";
        return resp;
    }

    // ==== Preferences ====
    @GetMapping("/user/preferences")
    public PreferencesResponse getPreferences(@RequestParam("id") long id) {
        Long roleId = getOrCreateOwnerRoleId(id);
        // load all preferences linked to this role
        List<RolePreference> links = rolePreferenceMapper.selectList(
                Wrappers.lambdaQuery(RolePreference.class).eq(RolePreference::getRoleId, roleId)
        );
        List<Long> prefIds = new ArrayList<>();
        for (RolePreference rp : links) {
            if (rp.getPreferenceId() != null) prefIds.add(rp.getPreferenceId());
        }
        Map<String, String> map = new HashMap<>();
        List<String> cuisines = new ArrayList<>();
        if (!prefIds.isEmpty()) {
            List<Preference> prefs = preferenceMapper.selectList(
                    Wrappers.lambdaQuery(Preference.class).in(Preference::getId, prefIds)
            );
            for (Preference p : prefs) {
                String name = p.getName();
                if (name == null) continue;
                if (name.startsWith("dietaryType:")) map.put("dietaryType", name.substring("dietaryType:".length()));
                else if (name.startsWith("spiceLevel:")) map.put("spiceLevel", name.substring("spiceLevel:".length()));
                else if (name.startsWith("cookingTimePreference:")) map.put("cookingTimePreference", name.substring("cookingTimePreference:".length()));
                else if (name.startsWith("cuisine:")) cuisines.add(name.substring("cuisine:".length()));
            }
        }
        PreferencesUpdateRequest body = new PreferencesUpdateRequest();
        body.dietaryType = map.getOrDefault("dietaryType", "");
        body.spiceLevel = map.getOrDefault("spiceLevel", "");
        body.cookingTimePreference = map.getOrDefault("cookingTimePreference", "");
        body.cuisineTypes = cuisines;
        PreferencesResponse r = new PreferencesResponse();
        r.userId = id;
        r.preferences = body;
        return r;
    }

    @PutMapping("/user/preferences")
    public UpdateMessageResponse updatePreferences(@RequestParam("id") long id,
                                                   @RequestBody PreferencesUpdateRequest req) {
        Long roleId = getOrCreateOwnerRoleId(id);
        // clear existing links
        rolePreferenceMapper.delete(Wrappers.lambdaQuery(RolePreference.class).eq(RolePreference::getRoleId, roleId));

        // upsert helper
        java.util.function.Function<String, Long> upsertPref = (String name) -> {
            if (name == null || name.isEmpty()) return null;
            Preference p = preferenceMapper.selectOne(Wrappers.lambdaQuery(Preference.class)
                    .eq(Preference::getName, name).last("limit 1"));
            if (p == null) {
                p = new Preference();
                p.setName(name);
                preferenceMapper.insert(p);
            }
            return p.getId();
        };

        // dietaryType - only create if not null and not empty
        if (req.dietaryType != null && !req.dietaryType.trim().isEmpty()) {
            Long id1 = upsertPref.apply("dietaryType:" + req.dietaryType);
            if (id1 != null) insertRolePref(roleId, id1);
        }
        // spiceLevel - only create if not null and not empty
        if (req.spiceLevel != null && !req.spiceLevel.trim().isEmpty()) {
            Long id2 = upsertPref.apply("spiceLevel:" + req.spiceLevel);
            if (id2 != null) insertRolePref(roleId, id2);
        }
        // cookingTimePreference - only create if not null and not empty
        if (req.cookingTimePreference != null && !req.cookingTimePreference.trim().isEmpty()) {
            Long id3 = upsertPref.apply("cookingTimePreference:" + req.cookingTimePreference);
            if (id3 != null) insertRolePref(roleId, id3);
        }
        // cuisines - only create if not null and not empty
        if (req.cuisineTypes != null) {
            for (String c : req.cuisineTypes) {
                if (c != null && !c.trim().isEmpty()) {
                    Long cid = upsertPref.apply("cuisine:" + c);
                    if (cid != null) insertRolePref(roleId, cid);
                }
            }
        }
        UpdateMessageResponse r = new UpdateMessageResponse();
        r.userId = id;
        r.message = "User preferences updated successfully";
        return r;
    }

    // ==== Taboos ====
    @GetMapping("/user/taboos")
    public TaboosResponse getTaboos(@RequestParam("id") long id) {
        Long roleId = getOrCreateOwnerRoleId(id);
        List<RoleRestriction> links = roleRestrictionMapper.selectList(
                Wrappers.lambdaQuery(RoleRestriction.class)
                        .eq(RoleRestriction::getRoleId, roleId)
                        .eq(RoleRestriction::getType, (short)2)
        );
        List<Long> resIds = new ArrayList<>();
        for (RoleRestriction rr : links) if (rr.getRestrictionId() != null) resIds.add(rr.getRestrictionId());
        List<String> names = new ArrayList<>();
        if (!resIds.isEmpty()) {
            List<Restriction> list = restrictionMapper.selectList(Wrappers.lambdaQuery(Restriction.class).in(Restriction::getId, resIds));
            for (Restriction rs : list) if (rs.getName() != null) names.add(rs.getName());
        }
        TaboosResponse r = new TaboosResponse();
        r.userId = id;
        r.taboos = names;
        return r;
    }

    @PutMapping("/user/taboos")
    public UpdateMessageResponse updateTaboos(@RequestParam("id") long id,
                                              @RequestBody TaboosUpdateRequest req) {
        Long roleId = getOrCreateOwnerRoleId(id);
        // clear existing type=2
        roleRestrictionMapper.delete(Wrappers.lambdaQuery(RoleRestriction.class)
                .eq(RoleRestriction::getRoleId, roleId).eq(RoleRestriction::getType, (short)2));
        if (req.taboos != null) {
            for (String name : req.taboos) {
                // Skip empty or null names
                if (name == null || name.trim().isEmpty()) continue;
                
                Restriction r = restrictionMapper.selectOne(Wrappers.lambdaQuery(Restriction.class)
                        .eq(Restriction::getName, name).last("limit 1"));
                if (r == null) {
                    r = new Restriction();
                    r.setName(name);
                    restrictionMapper.insert(r);
                }
                RoleRestriction link = new RoleRestriction();
                link.setRoleId(roleId);
                link.setRestrictionId(r.getId());
                link.setType((short)2); // taboo
                roleRestrictionMapper.insert(link);
            }
        }
        UpdateMessageResponse r = new UpdateMessageResponse();
        r.userId = id;
        r.message = "User taboos updated successfully";
        return r;
    }

    // ==== Allergies ====
    @GetMapping("/user/allergies")
    public AllergiesResponse getAllergies(@RequestParam("id") long id) {
        Long roleId = getOrCreateOwnerRoleId(id);
        List<RoleRestriction> links = roleRestrictionMapper.selectList(
                Wrappers.lambdaQuery(RoleRestriction.class)
                        .eq(RoleRestriction::getRoleId, roleId)
                        .eq(RoleRestriction::getType, (short)1)
        );
        List<Long> resIds = new ArrayList<>();
        for (RoleRestriction rr : links) if (rr.getRestrictionId() != null) resIds.add(rr.getRestrictionId());
        List<String> names = new ArrayList<>();
        if (!resIds.isEmpty()) {
            List<Restriction> list = restrictionMapper.selectList(Wrappers.lambdaQuery(Restriction.class).in(Restriction::getId, resIds));
            for (Restriction rs : list) if (rs.getName() != null) names.add(rs.getName());
        }
        AllergiesResponse r = new AllergiesResponse();
        r.userId = id;
        r.allergies = names;
        return r;
    }

    @PutMapping("/user/allergies")
    public UpdateMessageResponse updateAllergies(@RequestParam("id") long id,
                                                 @RequestBody AllergiesUpdateRequest req) {
        Long roleId = getOrCreateOwnerRoleId(id);
        // clear existing type=1
        roleRestrictionMapper.delete(Wrappers.lambdaQuery(RoleRestriction.class)
                .eq(RoleRestriction::getRoleId, roleId).eq(RoleRestriction::getType, (short)1));
        if (req.allergies != null) {
            for (String name : req.allergies) {
                // Skip empty or null names
                if (name == null || name.trim().isEmpty()) continue;
                
                Restriction r = restrictionMapper.selectOne(Wrappers.lambdaQuery(Restriction.class)
                        .eq(Restriction::getName, name).last("limit 1"));
                if (r == null) {
                    r = new Restriction();
                    r.setName(name);
                    restrictionMapper.insert(r);
                }
                RoleRestriction link = new RoleRestriction();
                link.setRoleId(roleId);
                link.setRestrictionId(r.getId());
                link.setType((short)1); // allergy
                roleRestrictionMapper.insert(link);
            }
        }
        UpdateMessageResponse r = new UpdateMessageResponse();
        r.userId = id;
        r.message = "User allergies updated successfully";
        return r;
    }

    // ====== Samples / DTOs ======
    private UserBrief sampleUser(long id) {
        UserBrief u = new UserBrief();
        u.userId = id;
        u.userName = "UserName";
        u.email = "user.email@example.com";
        Profile p = new Profile();
        // No default values - age, height, weight, gender will be null until user sets them
        p.age = null;
        p.height = null;
        p.weight = null;
        p.gender = null;
        u.profile = p;
        return u;
    }

    private PreferencesResponse samplePreferences(long id) {
        PreferencesResponse r = new PreferencesResponse();
        r.userId = id;
        PreferencesUpdateRequest p = new PreferencesUpdateRequest();
        p.dietaryType = "";
        p.cuisineTypes = new ArrayList<>();
        p.spiceLevel = "";
        p.cookingTimePreference = "";
        r.preferences = p;
        return r;
    }

    // ==== DTO classes matching docs ====
    public static class RegisterRequest {
        public String username;
        public String password;
        public String confirmPassword;
        public String email;
    }

    public static class RegisterResponse {
        public long userId;
        public String message;
    }

    public static class LoginRequest {
        public String identifier;
        public String password;
    }

    public static class Token {
        public String accessToken;
        public int expiresIn;
    }

    public static class LoginResponse {
        public long userId;
        public Token token;
        public String message; // Optional error message
    }

    public static class LogoutResponse {
        public String message;
    }

    public static class Profile {
        public Integer age; // Nullable - no default value
        public Integer height; // Nullable - no default value
        public Integer weight; // Nullable - no default value
        public String gender; // Optional
    }

    public static class UserBrief {
        public long userId;
        public String userName;
        public String email;
        public Profile profile;
    }

    public static class PreferencesUpdateRequest {
        public String dietaryType;
        public List<String> cuisineTypes;
        public String spiceLevel;
        public String cookingTimePreference;
    }

    public static class PreferencesResponse {
        public long userId;
        public PreferencesUpdateRequest preferences;
    }

    public static class UpdateMessageResponse {
        public long userId;
        public String message;
    }

    public static class TaboosUpdateRequest {
        public List<String> taboos;
    }

    public static class TaboosResponse {
        public long userId;
        public List<String> taboos;
    }

    public static class AllergiesUpdateRequest {
        public List<String> allergies;
    }

    public static class AllergiesResponse {
        public long userId;
        public List<String> allergies;
    }

    public static class UserBriefUpdateRequest {
        public Long userId;
        public String userName;
        public String email;
        public Profile profile;
    }

    // ===== Internal helpers =====
    private Long getOrCreateOwnerRoleId(Long userId) {
        UserRole exist = userRoleMapper.selectOne(Wrappers.lambdaQuery(UserRole.class)
                .eq(UserRole::getUserId, userId)
                .eq(UserRole::getAccountOwner, Boolean.TRUE)
                .last("limit 1"));
        if (exist != null) return exist.getId();
        UserRole ur = new UserRole();
        ur.setUserId(userId);
        ur.setAccountOwner(true);
        ur.setName("Owner");
        userRoleMapper.insert(ur);
        return ur.getId();
    }

    private void insertRolePref(Long roleId, Long prefId) {
        if (roleId == null || prefId == null) return;
        RolePreference rp = new RolePreference();
        rp.setRoleId(roleId);
        rp.setPreferenceId(prefId);
        rp.setLevel((short)1);
        rolePreferenceMapper.insert(rp);
    }

    private String nullToEmpty(String s) { return s == null ? "" : s; }
}
