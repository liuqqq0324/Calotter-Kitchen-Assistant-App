package com.calotter.user.repository;

import com.calotter.common.core.domain.entity.RefAllergen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RefAllergenRepository extends JpaRepository<RefAllergen, Long> {
    Optional<RefAllergen> findByName(String name);
    List<RefAllergen> findByNameIn(List<String> names);
}
