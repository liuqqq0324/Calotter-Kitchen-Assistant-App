package io.github.linpeilie;

import com.calotter.inventory.domain.UserIngredientToUserIngredientVoMapper;
import com.calotter.inventory.domain.UserKitchenwareToUserKitchenwareVoMapper;
import com.calotter.inventory.domain.bo.UserIngredientBoToUserIngredientMapper;
import com.calotter.inventory.domain.bo.UserKitchenwareBoToUserKitchenwareMapper;
import com.calotter.inventory.domain.vo.UserIngredientVoToUserIngredientMapper;
import com.calotter.inventory.domain.vo.UserKitchenwareVoToUserKitchenwareMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__130.class, UserIngredientToUserIngredientVoMapper.class, UserIngredientBoToUserIngredientMapper.class, UserKitchenwareToUserKitchenwareVoMapper.class, UserKitchenwareVoToUserKitchenwareMapper.class, UserIngredientVoToUserIngredientMapper.class, UserKitchenwareBoToUserKitchenwareMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__130 {
}
