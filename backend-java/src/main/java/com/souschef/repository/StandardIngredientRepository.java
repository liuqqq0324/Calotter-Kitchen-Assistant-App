package com.souschef.repository;

import com.souschef.entity.StandardIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StandardIngredientRepository extends JpaRepository<StandardIngredient, Integer> {
}


