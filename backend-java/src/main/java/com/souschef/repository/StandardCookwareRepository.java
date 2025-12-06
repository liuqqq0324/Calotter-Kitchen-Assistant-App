package com.souschef.repository;

import com.souschef.entity.StandardCookware;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StandardCookwareRepository extends JpaRepository<StandardCookware, Integer> {
}


