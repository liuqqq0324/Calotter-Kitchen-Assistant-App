package com.souschef.controller;

import com.souschef.entity.StandardIngredient;
import com.souschef.repository.StandardIngredientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/StandardLibrary")
@CrossOrigin(origins = "*")
public class StandardLibraryController {
    
    @Autowired
    private StandardIngredientRepository standardIngredientRepository;
    
    @GetMapping("/ingredients")
    public List<StandardIngredient> getIngredients() {
        return standardIngredientRepository.findAll();
    }
}


