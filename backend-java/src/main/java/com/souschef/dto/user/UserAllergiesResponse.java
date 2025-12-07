package com.souschef.dto.user;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class UserAllergiesResponse {
    private Long userId;
    private List<String> allergies = new ArrayList<>();
}


