package com.calotter.inventory.repository;

import com.calotter.common.core.domain.entity.StandardUtensil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StandardUtensilRepository extends JpaRepository<StandardUtensil, Long> {
}
