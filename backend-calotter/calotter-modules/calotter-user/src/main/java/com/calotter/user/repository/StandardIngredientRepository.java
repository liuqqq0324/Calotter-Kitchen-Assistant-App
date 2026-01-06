package com.calotter.user.repository;

import com.calotter.common.core.domain.entity.StandardIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * StandardIngredient repository for user module (avoid importing inventory module).
 * Used for validating/searching avoid-ingredients selections from the standard ingredient library.
 */
@Repository
public interface StandardIngredientRepository extends JpaRepository<StandardIngredient, Long> {
    Optional<StandardIngredient> findFirstByNameIgnoreCase(String name);

    @Query("SELECT s FROM StandardIngredient s WHERE LOWER(s.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<StandardIngredient> findByNameContainingIgnoreCase(@Param("name") String name);
}


