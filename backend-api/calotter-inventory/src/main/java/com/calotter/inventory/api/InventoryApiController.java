package com.calotter.inventory.api;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.calotter.inventory.domain.UserIngredient;
import com.calotter.inventory.mapper.UserIngredientMapper;
import com.calotter.inventory.support.RmsIngredient;
import com.calotter.inventory.mapper.RmsIngredientMapper;
import com.calotter.inventory.support.RmsKitchenware;
import com.calotter.inventory.mapper.RmsKitchenwareMapper;
import com.calotter.inventory.domain.UserKitchenware;
import com.calotter.inventory.mapper.UserKitchenwareMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.*;

/**
 * IMS APIs to satisfy documentation formats (success path only).
 */
@RestController
@RequestMapping("/api/ims")
@RequiredArgsConstructor
public class InventoryApiController {

    private final UserIngredientMapper userIngredientMapper;
    private final RmsIngredientMapper rmsIngredientMapper;
    private final UserKitchenwareMapper userKitchenwareMapper;
    private final RmsKitchenwareMapper rmsKitchenwareMapper;

    // keep in-memory only for seasonings success-path (no table in DDL)
    private final Map<String, Boolean> seasonings = new HashMap<>();

    // ==== Inventory ====
    @GetMapping("/inventory")
    public List<InventoryResponseItem> getInventory(@RequestParam("userId") Long userId) {
        LambdaQueryWrapper<UserIngredient> lqw = Wrappers.lambdaQuery(UserIngredient.class)
                .eq(UserIngredient::getUserId, userId)
                .orderByAsc(UserIngredient::getId);
        List<UserIngredient> items = userIngredientMapper.selectList(lqw);
        // batch load ingredient names/images
        Map<Long, RmsIngredient> ingMap = Collections.emptyMap();
        if (!items.isEmpty()) {
            Set<Long> ingIds = new HashSet<>();
            for (UserIngredient ui : items) {
                if (ui.getIngredientId() != null) ingIds.add(ui.getIngredientId());
            }
            if (!ingIds.isEmpty()) {
                List<RmsIngredient> ings = rmsIngredientMapper.selectList(
                        Wrappers.lambdaQuery(RmsIngredient.class).in(RmsIngredient::getId, ingIds)
                );
                ingMap = new HashMap<>();
                for (RmsIngredient ig : ings) ingMap.put(ig.getId(), ig);
            }
        }
        List<InventoryResponseItem> list = new ArrayList<>();
        for (UserIngredient it : items) {
            InventoryResponseItem r = new InventoryResponseItem();
            r.inventory_id = String.valueOf(it.getId());
            RmsIngredient base = it.getIngredientId() != null ? ingMap.get(it.getIngredientId()) : null;
            r.name = base != null ? base.getName() : null;
            r.image_url = base != null ? base.getImageUrl() : null;
            r.quantity = it.getQuantity() != null ? it.getQuantity() : 0.0;
            r.unit = it.getCurrentUnit();
            r.expiry_date = it.getExpirationDate() != null ? it.getExpirationDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate().toString() : null;
            list.add(r);
        }
        return list;
    }

    @PostMapping("/inventory")
    public AddInventoryResponse addInventory(@RequestParam("userId") Long userId,
                                             @RequestBody AddInventoryRequest req) {
        // resolve or create ingredient by name
        RmsIngredient ing = rmsIngredientMapper.selectOne(
                Wrappers.lambdaQuery(RmsIngredient.class)
                        .eq(RmsIngredient::getName, req.name)
                        .last("limit 1")
        );
        if (ing == null) {
            ing = new RmsIngredient();
            ing.setName(req.name);
            // optional: set image url using a simple rule
            ing.setImageUrl(sampleImage(req.name));
            rmsIngredientMapper.insert(ing);
        }

        UserIngredient ui = new UserIngredient();
        ui.setUserId(userId);
        ui.setIngredientId(ing.getId());
        ui.setQuantity(req.quantity);
        ui.setCurrentUnit(req.unit);
        if (req.expiry_date != null) {
            LocalDate ld = LocalDate.parse(req.expiry_date);
            ui.setExpirationDate(java.util.Date.from(ld.atStartOfDay(ZoneId.systemDefault()).toInstant()));
        }
        userIngredientMapper.insert(ui);

        AddInventoryResponse resp = new AddInventoryResponse();
        resp.inventory_id = String.valueOf(ui.getId());
        resp.status = "success";
        resp.message = "Item added";
        return resp;
    }

    @PutMapping("/inventory")
    public void editInventory(@RequestParam("userId") Long userId,
                              @RequestBody EditInventoryRequest req) {
        if (req.inventory_id == null) return;
        UserIngredient ui = userIngredientMapper.selectById(req.inventory_id);
        if (ui == null || !Objects.equals(ui.getUserId(), userId)) return;
        if (req.quantity != null) ui.setQuantity(req.quantity);
        if (req.unit != null) ui.setCurrentUnit(req.unit);
        if (req.expiry_date != null) {
            LocalDate ld = LocalDate.parse(req.expiry_date);
            ui.setExpirationDate(java.util.Date.from(ld.atStartOfDay(ZoneId.systemDefault()).toInstant()));
        }
        userIngredientMapper.updateById(ui);
    }

    @DeleteMapping("/inventory")
    public void deleteInventory(@RequestParam("userId") Long userId,
                                @RequestBody DeleteInventoryRequest req) {
        if (req.inventory_id == null) return;
        UserIngredient ui = userIngredientMapper.selectById(req.inventory_id);
        if (ui != null && Objects.equals(ui.getUserId(), userId)) {
            userIngredientMapper.deleteById(ui.getId());
        }
    }

    // ==== Cookware toggle ====
    @PostMapping("/cookware/toggle")
    public CookwareToggleResponse toggleCookware(@RequestParam("userId") Long userId,
                                                 @RequestBody CookwareToggleRequest req) {
        // resolve or create kitchenware by name; use request.cookware_id as external code if provided
        RmsKitchenware kw = null;
        if (req.name != null) {
            kw = rmsKitchenwareMapper.selectOne(Wrappers.lambdaQuery(RmsKitchenware.class)
                    .eq(RmsKitchenware::getName, req.name)
                    .last("limit 1"));
        }
        if (kw == null) {
            kw = new RmsKitchenware();
            kw.setName(req.name != null ? req.name : req.cookware_id);
            rmsKitchenwareMapper.insert(kw);
        }

        // check ownership
        UserKitchenware link = userKitchenwareMapper.selectOne(Wrappers.lambdaQuery(UserKitchenware.class)
                .eq(UserKitchenware::getUserId, userId)
                .eq(UserKitchenware::getKitchenwareId, kw.getId())
                .last("limit 1"));
        boolean next;
        if (link == null) {
            link = new UserKitchenware();
            link.setUserId(userId);
            link.setKitchenwareId(kw.getId());
            link.setConditionStatus("OWNED");
            userKitchenwareMapper.insert(link);
            next = true;
        } else {
            // toggle by delete/insert for simplicity
            userKitchenwareMapper.deleteById(link.getId());
            next = false;
        }

        CookwareToggleResponse r = new CookwareToggleResponse();
        r.cookware_id = req.cookware_id;
        r.name = req.name != null ? req.name : kw.getName();
        r.is_available = next;
        return r;
    }

    // ==== Seasoning toggle ====
    @PostMapping("/seasoning/toggle")
    public SeasoningToggleResponse toggleSeasoning(@RequestBody SeasoningToggleRequest req) {
        boolean next = !seasonings.getOrDefault(req.seasoning_id, false);
        seasonings.put(req.seasoning_id, next);
        SeasoningToggleResponse r = new SeasoningToggleResponse();
        r.seasoning_id = req.seasoning_id;
        r.name = req.name;
        r.is_available = next;
        return r;
    }

    private String sampleImage(String name) {
        String base = "https://server.com/static/";
        return base + name.toLowerCase().replace(' ', '_') + ".png";
    }

    // ===== DTOs =====
    public static class InventoryResponseItem {
        public String inventory_id;
        public String name;
        public String image_url;
        public double quantity;
        public String unit;
        public String expiry_date;
    }

    public static class AddInventoryRequest {
        public String name;
        public double quantity;
        public String unit;
        public String expiry_date;
    }

    public static class AddInventoryResponse {
        public String inventory_id;
        public String status;
        public String message;
    }

    public static class EditInventoryRequest {
        public String inventory_id;
        public Double quantity;
        public String unit;
        public String expiry_date;
    }

    public static class DeleteInventoryRequest {
        public String inventory_id;
    }

    public static class CookwareToggleRequest {
        public String cookware_id;
        public String name;
    }

    public static class CookwareToggleResponse {
        public String cookware_id;
        public String name;
        public boolean is_available;
    }

    public static class SeasoningToggleRequest {
        public String seasoning_id;
        public String name;
    }

    public static class SeasoningToggleResponse {
        public String seasoning_id;
        public String name;
        public boolean is_available;
    }

    // note: seasonings endpoints remain in-memory for success-path only
}
