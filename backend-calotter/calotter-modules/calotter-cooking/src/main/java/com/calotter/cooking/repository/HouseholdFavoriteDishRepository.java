package com.calotter.cooking.repository;

import com.calotter.cooking.domain.entity.HouseholdFavoriteDish;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HouseholdFavoriteDishRepository extends JpaRepository<HouseholdFavoriteDish, Long> {
    Optional<HouseholdFavoriteDish> findByHouseholdIdAndDishId(Long householdId, Long dishId);
    List<HouseholdFavoriteDish> findByHouseholdId(Long householdId);
    long deleteByHouseholdIdAndDishId(Long householdId, Long dishId);
    boolean existsByHouseholdIdAndDishId(Long householdId, Long dishId);
}


