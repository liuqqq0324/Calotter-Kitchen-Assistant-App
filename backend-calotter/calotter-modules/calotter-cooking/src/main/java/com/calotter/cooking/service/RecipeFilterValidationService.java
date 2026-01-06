package com.calotter.cooking.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.inventory.repository.StandardIngredientRepository;
import com.calotter.user.repository.RefAllergenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Validate RecipeGenerationFilter against standard libraries.
 *
 * Goal: cooking filter must align with user module and restrict input to standard libraries.
 */
@Service
@RequiredArgsConstructor
public class RecipeFilterValidationService {

    private final RefAllergenRepository refAllergenRepository;
    private final StandardIngredientRepository standardIngredientRepository;

    public void validate(RecipeGenerationFilter filter) {
        if (filter == null || filter.getDietPreferences() == null) return;
        RecipeGenerationFilter.DietPreferences dp = filter.getDietPreferences();

        // cuisine / taste options are from PreferenceStandardLibrary
        if (dp.getCuisinePreferences() != null) {
            List<String> invalid = dp.getCuisinePreferences().stream()
                    .filter(c -> c != null && !c.trim().isEmpty())
                    .filter(c -> !PreferenceStandardLibrary.isValidCuisine(c))
                    .toList();
            if (!invalid.isEmpty()) {
                throw new IllegalArgumentException(
                        "Invalid cuisinePreferences: " + String.join(", ", invalid) +
                                ". Must be one of: " + String.join(", ", PreferenceStandardLibrary.CUISINE_OPTIONS)
                );
            }
        }

        if (dp.getTastePreferences() != null) {
            List<String> invalid = dp.getTastePreferences().stream()
                    .filter(t -> t != null && !t.trim().isEmpty())
                    .filter(t -> !PreferenceStandardLibrary.isValidTaste(t))
                    .toList();
            if (!invalid.isEmpty()) {
                throw new IllegalArgumentException(
                        "Invalid tastePreferences: " + String.join(", ", invalid) +
                                ". Must be one of: " + String.join(", ", PreferenceStandardLibrary.TASTE_OPTIONS)
                );
            }
        }

        // taboos are strict, must be from TABOO_OPTIONS
        if (dp.getTaboos() != null) {
            List<String> invalid = dp.getTaboos().stream()
                    .filter(t -> t != null && !t.trim().isEmpty())
                    .map(t -> t.trim().toLowerCase())
                    .filter(t -> !PreferenceStandardLibrary.isValidTaboo(t))
                    .toList();
            if (!invalid.isEmpty()) {
                throw new IllegalArgumentException(
                        "Invalid taboos: " + String.join(", ", invalid) +
                                ". Must be one of: " + String.join(", ", PreferenceStandardLibrary.TABOO_OPTIONS)
                );
            }
        }

        // allergies must exist in ref_standard_allergens
        if (dp.getAllergies() != null) {
            List<String> names = dp.getAllergies().stream()
                    .filter(a -> a != null && !a.trim().isEmpty())
                    .map(String::trim)
                    .distinct()
                    .toList();
            if (!names.isEmpty()) {
                List<RefAllergen> found = refAllergenRepository.findByNameIn(names);
                List<String> foundNames = found.stream().map(RefAllergen::getName).collect(Collectors.toList());
                List<String> invalid = names.stream().filter(n -> !foundNames.contains(n)).toList();
                if (!invalid.isEmpty()) {
                    throw new IllegalArgumentException("Invalid allergies (not in standard library): " + String.join(", ", invalid));
                }
            }
        }

        // avoid ingredients must exist in standard ingredients library
        if (dp.getAvoidIngredients() != null) {
            List<String> invalid = new ArrayList<>();
            for (String ing : dp.getAvoidIngredients()) {
                if (ing == null || ing.trim().isEmpty()) continue;
                if (standardIngredientRepository.findFirstByNameIgnoreCase(ing.trim()).isEmpty()) {
                    invalid.add(ing.trim());
                }
            }
            if (!invalid.isEmpty()) {
                throw new IllegalArgumentException(
                        "Invalid avoidIngredients (not in standard ingredient library): " + String.join(", ", invalid)
                );
            }
        }
    }
}


