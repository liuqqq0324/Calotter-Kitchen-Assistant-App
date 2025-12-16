package com.calotter.inventory.controller;

import com.calotter.common.core.Result;
import com.calotter.inventory.controller.dto.*;
import com.calotter.inventory.service.InventoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 库存控制器
 */
@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    // ==================== 食材管理 ====================

    /**
     * 创建食材
     * POST /api/inventory/ingredients
     */
    @PostMapping("/ingredients")
    public Result<IngredientResponse> createIngredient(@Valid @RequestBody IngredientRequest request) {
        try {
            IngredientResponse response = inventoryService.createIngredient(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新食材
     * PUT /api/inventory/ingredients/{id}
     */
    @PutMapping("/ingredients/{id}")
    public Result<IngredientResponse> updateIngredient(
            @PathVariable Long id,
            @Valid @RequestBody IngredientRequest request) {
        try {
            IngredientResponse response = inventoryService.updateIngredient(id, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取食材详情
     * GET /api/inventory/ingredients/{id}
     */
    @GetMapping("/ingredients/{id}")
    public Result<IngredientResponse> getIngredient(@PathVariable Long id) {
        try {
            IngredientResponse response = inventoryService.getIngredient(id);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取家庭的所有食材
     * GET /api/inventory/ingredients?householdId={householdId}
     */
    @GetMapping("/ingredients")
    public Result<List<IngredientResponse>> getIngredients(@RequestParam("householdId") Long householdId) {
        try {
            List<IngredientResponse> responses = inventoryService.getIngredientsByHousehold(householdId);
            return Result.success(responses);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除食材
     * DELETE /api/inventory/ingredients/{id}
     */
    @DeleteMapping("/ingredients/{id}")
    public Result<Void> deleteIngredient(@PathVariable Long id) {
        try {
            inventoryService.deleteIngredient(id);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 扣减食材库存
     * POST /api/inventory/ingredients/{id}/deduct
     */
    @PostMapping("/ingredients/{id}/deduct")
    public Result<Void> deductIngredient(
            @PathVariable Long id,
            @RequestParam("amount") Double amount) {
        try {
            inventoryService.deductIngredient(id, amount);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    // ==================== 标准食材库查询 ====================

    /**
     * 通过名称查找标准食材
     * GET /api/inventory/standard-ingredients/search?name={name}&fuzzy={fuzzy}
     * - fuzzy=false: 精确匹配，返回单个结果
     * - fuzzy=true: 模糊匹配，返回列表
     */
    @GetMapping("/standard-ingredients/search")
    public Result<?> searchStandardIngredients(
            @RequestParam("name") String name,
            @RequestParam(value = "fuzzy", defaultValue = "false") boolean fuzzy) {
        try {
            if (fuzzy) {
                // 模糊匹配，返回列表
                List<com.calotter.common.core.domain.entity.StandardIngredient> ingredients = 
                        inventoryService.searchStandardIngredientsByName(name);
                return Result.success(ingredients);
            } else {
                // 精确匹配，返回单个结果
                com.calotter.common.core.domain.entity.StandardIngredient ingredient = 
                        inventoryService.findStandardIngredientByName(name);
                return Result.success(ingredient);
            }
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    // ==================== 调料管理 ====================

    /**
     * 创建调料
     * POST /api/inventory/spices
     */
    @PostMapping("/spices")
    public Result<SpiceResponse> createSpice(@Valid @RequestBody SpiceRequest request) {
        try {
            SpiceResponse response = inventoryService.createSpice(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新调料
     * PUT /api/inventory/spices/{id}
     */
    @PutMapping("/spices/{id}")
    public Result<SpiceResponse> updateSpice(
            @PathVariable Long id,
            @Valid @RequestBody SpiceRequest request) {
        try {
            SpiceResponse response = inventoryService.updateSpice(id, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取调料详情
     * GET /api/inventory/spices/{id}
     */
    @GetMapping("/spices/{id}")
    public Result<SpiceResponse> getSpice(@PathVariable Long id) {
        try {
            SpiceResponse response = inventoryService.getSpice(id);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取家庭的所有调料
     * GET /api/inventory/spices?householdId={householdId}
     */
    @GetMapping("/spices")
    public Result<List<SpiceResponse>> getSpices(@RequestParam("householdId") Long householdId) {
        try {
            List<SpiceResponse> responses = inventoryService.getSpicesByHousehold(householdId);
            return Result.success(responses);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除调料
     * DELETE /api/inventory/spices/{id}
     */
    @DeleteMapping("/spices/{id}")
    public Result<Void> deleteSpice(@PathVariable Long id) {
        try {
            inventoryService.deleteSpice(id);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    // ==================== 厨具管理 ====================

    /**
     * 创建厨具
     * POST /api/inventory/utensils
     */
    @PostMapping("/utensils")
    public Result<UtensilResponse> createUtensil(@Valid @RequestBody UtensilRequest request) {
        try {
            UtensilResponse response = inventoryService.createUtensil(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新厨具
     * PUT /api/inventory/utensils/{id}
     */
    @PutMapping("/utensils/{id}")
    public Result<UtensilResponse> updateUtensil(
            @PathVariable Long id,
            @Valid @RequestBody UtensilRequest request) {
        try {
            UtensilResponse response = inventoryService.updateUtensil(id, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取厨具详情
     * GET /api/inventory/utensils/{id}
     */
    @GetMapping("/utensils/{id}")
    public Result<UtensilResponse> getUtensil(@PathVariable Long id) {
        try {
            UtensilResponse response = inventoryService.getUtensil(id);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取家庭的所有厨具
     * GET /api/inventory/utensils?householdId={householdId}
     */
    @GetMapping("/utensils")
    public Result<List<UtensilResponse>> getUtensils(@RequestParam("householdId") Long householdId) {
        try {
            List<UtensilResponse> responses = inventoryService.getUtensilsByHousehold(householdId);
            return Result.success(responses);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除厨具
     * DELETE /api/inventory/utensils/{id}
     */
    @DeleteMapping("/utensils/{id}")
    public Result<Void> deleteUtensil(@PathVariable Long id) {
        try {
            inventoryService.deleteUtensil(id);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    // ==================== 剩菜管理 ====================

    /**
     * 创建剩菜
     * POST /api/inventory/leftovers
     */
    @PostMapping("/leftovers")
    public Result<LeftoverResponse> createLeftover(@Valid @RequestBody LeftoverRequest request) {
        try {
            LeftoverResponse response = inventoryService.createLeftover(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新剩菜
     * PUT /api/inventory/leftovers/{id}
     */
    @PutMapping("/leftovers/{id}")
    public Result<LeftoverResponse> updateLeftover(
            @PathVariable Long id,
            @Valid @RequestBody LeftoverRequest request) {
        try {
            LeftoverResponse response = inventoryService.updateLeftover(id, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取剩菜详情
     * GET /api/inventory/leftovers/{id}
     */
    @GetMapping("/leftovers/{id}")
    public Result<LeftoverResponse> getLeftover(@PathVariable Long id) {
        try {
            LeftoverResponse response = inventoryService.getLeftover(id);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取家庭的所有剩菜
     * GET /api/inventory/leftovers?householdId={householdId}
     */
    @GetMapping("/leftovers")
    public Result<List<LeftoverResponse>> getLeftovers(@RequestParam("householdId") Long householdId) {
        try {
            List<LeftoverResponse> responses = inventoryService.getLeftoversByHousehold(householdId);
            return Result.success(responses);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除剩菜
     * DELETE /api/inventory/leftovers/{id}
     */
    @DeleteMapping("/leftovers/{id}")
    public Result<Void> deleteLeftover(@PathVariable Long id) {
        try {
            inventoryService.deleteLeftover(id);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }
}
