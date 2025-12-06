package com.souschef.repository;

import com.souschef.entity.StandardSeasoning;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StandardSeasoningRepository extends JpaRepository<StandardSeasoning, Integer> {
}

