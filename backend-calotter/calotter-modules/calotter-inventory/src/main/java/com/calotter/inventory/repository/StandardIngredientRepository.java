package com.calotter.inventory.repository;

import com.calotter.common.core.domain.entity.StandardIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StandardIngredientRepository extends JpaRepository<StandardIngredient, Long> {
}
