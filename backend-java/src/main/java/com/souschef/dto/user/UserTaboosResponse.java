package com.souschef.dto.user;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class UserTaboosResponse {
    private Long userId;
    private List<String> taboos = new ArrayList<>();
}


