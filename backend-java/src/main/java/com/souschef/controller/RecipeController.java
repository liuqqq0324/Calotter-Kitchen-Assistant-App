package com.souschef.controller;

import com.souschef.dto.recipe.*;
import com.souschef.service.RecipeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rms/recipe")
@CrossOrigin(origins = "*")
public class RecipeController {
    
    @Autowired
    private RecipeService recipeService;
    
    /**
     * 生成食谱菜单
     * POST /api/rms/recipe/generate
     */
    @PostMapping("/generate")
    public ResponseEntity<?> generateRecipeMenus(@RequestBody RecipeGenerateRequest request) {
        try {
            // 验证必填字段
            if (request.getServings() == null || request.getServings() <= 0) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("servings is required and must be greater than 0"));
            }
            
            if (request.getResolvedDishCount() == null || request.getResolvedDishCount() <= 0) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(new ErrorResponse("dishCount is required and must be greater than 0"));
            }
            
            List<RecipeMenuResponse> menus = recipeService.generateRecipeMenus(request);
            
            return ResponseEntity.ok(new RecipeGenerateResponse(menus));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to generate recipes: " + e.getMessage()));
        }
    }
    
    /**
     * 获取单个食谱详情
     * GET /api/rms/recipe/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getRecipeById(@PathVariable Integer id) {
        try {
            RecipeResponse recipe = recipeService.getRecipeById(id);
            if (recipe == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse("Recipe not found"));
            }
            return ResponseEntity.ok(recipe);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Failed to get recipe: " + e.getMessage()));
        }
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
}
