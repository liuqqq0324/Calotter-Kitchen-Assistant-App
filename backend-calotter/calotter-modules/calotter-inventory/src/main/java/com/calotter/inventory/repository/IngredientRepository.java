package com.calotter.inventory.repository;

import com.calotter.inventory.domain.entity.Ingredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IngredientRepository extends JpaRepository<Ingredient, Long> {
    List<Ingredient> findByHouseholdIdAndQuantityGreaterThan(Long householdId, Double quantity);
    List<Ingredient> findByHouseholdId(Long householdId);
}
