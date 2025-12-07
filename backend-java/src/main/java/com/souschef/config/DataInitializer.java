package com.souschef.config;

import com.souschef.entity.StandardCookware;
import com.souschef.entity.StandardIngredient;
import com.souschef.entity.StandardSeasoning;
import com.souschef.repository.StandardCookwareRepository;
import com.souschef.repository.StandardIngredientRepository;
import com.souschef.repository.StandardSeasoningRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {
    
    @Autowired
    private StandardIngredientRepository standardIngredientRepository;
    
    @Autowired
    private StandardCookwareRepository standardCookwareRepository;
    
    @Autowired
    private StandardSeasoningRepository standardSeasoningRepository;
    
    @Override
    public void run(String... args) throws Exception {
        initializeStandardIngredients();
        initializeStandardCookwares();
        initializeStandardSeasonings();
    }
    
    private void initializeStandardIngredients() {
        if (standardIngredientRepository.count() == 0) {
            List<StandardIngredient> ingredients = List.of(
                new StandardIngredient(1, "Beef Steak", "Meat", "g", ""),
                new StandardIngredient(2, "Chicken Breast", "Meat", "g", ""),
                new StandardIngredient(3, "Pork Belly", "Meat", "g", ""),
                new StandardIngredient(4, "Egg", "Dairy", "piece", ""),
                new StandardIngredient(5, "Tomato", "Vegetable", "g", ""),
                new StandardIngredient(6, "Potato", "Vegetable", "g", ""),
                new StandardIngredient(7, "Onion", "Vegetable", "g", ""),
                new StandardIngredient(8, "Rice", "Grains", "g", ""),
                new StandardIngredient(9, "Peanut", "Nuts", "g", ""),
                new StandardIngredient(10, "Carrot", "Vegetable", "g", ""),
                new StandardIngredient(11, "Milk", "Dairy", "ml", ""),
                new StandardIngredient(12, "Cheese", "Dairy", "g", "")
            );
            standardIngredientRepository.saveAll(ingredients);
        }
    }
    
    private void initializeStandardCookwares() {
        if (standardCookwareRepository.count() == 0) {
            List<StandardCookware> cookwares = List.of(
                new StandardCookware(1, "Stove Top", "stove"),
                new StandardCookware(2, "Oven", "oven"),
                new StandardCookware(3, "Microwave", "microwave"),
                new StandardCookware(4, "Air Fryer", "air_fryer"),
                new StandardCookware(5, "Rice Cooker", "rice_cooker"),
                new StandardCookware(6, "Pressure Cooker", "pressure_cooker"),
                new StandardCookware(7, "Blender", "blender")
            );
            standardCookwareRepository.saveAll(cookwares);
        }
    }
    
    private void initializeStandardSeasonings() {
        if (standardSeasoningRepository.count() == 0) {
            List<StandardSeasoning> seasonings = List.of(
                new StandardSeasoning(1, "Salt", "salt"),
                new StandardSeasoning(2, "Sugar", "sugar"),
                new StandardSeasoning(3, "Soy Sauce", "soy_sauce"),
                new StandardSeasoning(4, "Black Pepper", "black_pepper"),
                new StandardSeasoning(5, "Olive Oil", "oil"),
                new StandardSeasoning(6, "Vinegar", "vinegar"),
                new StandardSeasoning(7, "Chili Powder", "chili_powder"),
                new StandardSeasoning(8, "Garlic Powder", "garlic_powder")
            );
            standardSeasoningRepository.saveAll(seasonings);
        }
    }
}


