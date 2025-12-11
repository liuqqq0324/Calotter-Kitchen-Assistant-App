package com.souschef.dto.intake;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateIntakeRequest {
    
    private BigDecimal consumedPercentage;
}
