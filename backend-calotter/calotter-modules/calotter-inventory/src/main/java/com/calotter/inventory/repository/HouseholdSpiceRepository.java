package com.calotter.inventory.repository;

import com.calotter.inventory.domain.entity.HouseholdSpice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HouseholdSpiceRepository extends JpaRepository<HouseholdSpice, Long> {
    List<HouseholdSpice> findByHouseholdIdAndIsAvailableTrue(Long householdId);
    List<HouseholdSpice> findByHouseholdId(Long householdId);
}
