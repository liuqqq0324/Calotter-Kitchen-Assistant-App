package com.souschef.dto.intake;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddManualIntakeRequest {
    
    private LocalDate date;
    private String foodName;
    private String portionDescription;
}
