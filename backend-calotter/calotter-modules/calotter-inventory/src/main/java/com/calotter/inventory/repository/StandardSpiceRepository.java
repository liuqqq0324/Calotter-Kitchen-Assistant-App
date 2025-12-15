package com.calotter.inventory.repository;

import com.calotter.common.core.domain.entity.StandardSpice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StandardSpiceRepository extends JpaRepository<StandardSpice, Long> {
}
