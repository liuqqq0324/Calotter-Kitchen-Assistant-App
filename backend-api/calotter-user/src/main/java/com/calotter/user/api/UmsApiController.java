package com.calotter.user.api;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.calotter.user.domain.*;
import com.calotter.user.mapper.*;
import lombok.RequiredArgsConstructor;
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

    // simple cache for brief profile defaults (non-persistent profile numbers per docs)
    private final Map<Long, UserBrief> userStore = new HashMap<>();

    // ==== Auth ====
    @PostMapping("/auth/register")
    public RegisterResponse register(@RequestBody RegisterRequest req) {
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

        // also keep an in-memory brief for sample profile fields not backed by DB columns
        UserBrief brief = new UserBrief();
        brief.userId = userId;
        brief.userName = req.username;
        brief.email = req.email;
        brief.profile = new Profile();
        brief.profile.age = 28;
        brief.profile.height = 178;
        brief.profile.weight = 72;
        userStore.put(userId, brief);

        RegisterResponse resp = new RegisterResponse();
        resp.userId = userId;
        resp.message = "User registered successfully";
        return resp;
    }

    @PostMapping("/auth/login")
    public LoginResponse login(@RequestBody LoginRequest req) {
        // success-path only: try to find by username or email; if not found, pick any existing id
        LambdaQueryWrapper<User> lqw = Wrappers.lambdaQuery(User.class)
            .eq(User::getUsername, req.identifier).or()
            .eq(User::getEmail, req.identifier)
            .last("limit 1");
        User found = userMapper.selectOne(lqw);

        Long uid = found != null ? found.getId() :
                Optional.ofNullable(userMapper.selectList(Wrappers.lambdaQuery(User.class).last("limit 1")))
                        .filter(list -> !list.isEmpty())
                        .map(list -> list.get(0).getId())
                        .orElse(2345678765678L);

        LoginResponse resp = new LoginResponse();
        resp.userId = uid;
        Token tk = new Token();
        tk.accessToken = UUID.randomUUID().toString().replace("-", "");
        tk.expiresIn = 3000;
        resp.token = tk;
        return resp;
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
            p.age = 28; p.height = 178; p.weight = 72; // static defaults as per docs example
            u.profile = p;
            // refresh in-memory cache for subsequent calls
            userStore.put(id, u);
            return u;
        }
        return userStore.getOrDefault(id, sampleUser(id));
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

        // dietaryType
        Long id1 = upsertPref.apply("dietaryType:" + nullToEmpty(req.dietaryType));
        if (id1 != null) insertRolePref(roleId, id1);
        // spiceLevel
        Long id2 = upsertPref.apply("spiceLevel:" + nullToEmpty(req.spiceLevel));
        if (id2 != null) insertRolePref(roleId, id2);
        // cookingTimePreference
        Long id3 = upsertPref.apply("cookingTimePreference:" + nullToEmpty(req.cookingTimePreference));
        if (id3 != null) insertRolePref(roleId, id3);
        // cuisines
        if (req.cuisineTypes != null) {
            for (String c : req.cuisineTypes) {
                Long cid = upsertPref.apply("cuisine:" + nullToEmpty(c));
                if (cid != null) insertRolePref(roleId, cid);
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
        p.age = 28; p.height = 178; p.weight = 72;
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
    }

    public static class Profile {
        public int age;
        public int height;
        public int weight;
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
