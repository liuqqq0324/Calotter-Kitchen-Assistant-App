package com.calotter.inventory.repository;

import com.calotter.inventory.domain.entity.HouseholdUtensil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HouseholdUtensilRepository extends JpaRepository<HouseholdUtensil, Long> {
    List<HouseholdUtensil> findByHouseholdIdAndIsAvailableTrue(Long householdId);
    List<HouseholdUtensil> findByHouseholdId(Long householdId);
}
