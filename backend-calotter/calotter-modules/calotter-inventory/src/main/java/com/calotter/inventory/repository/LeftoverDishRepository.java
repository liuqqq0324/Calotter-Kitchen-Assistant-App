package com.calotter.inventory.repository;

import com.calotter.inventory.domain.entity.LeftoverDish;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LeftoverDishRepository extends JpaRepository<LeftoverDish, Long> {
    List<LeftoverDish> findByHouseholdId(Long householdId);
}
