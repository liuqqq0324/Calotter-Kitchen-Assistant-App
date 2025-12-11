package io.github.linpeilie;

import com.calotter.cook.domain.RecipeIngredientHistoryToRecipeIngredientHistoryVoMapper;
import com.calotter.cook.domain.SessionRecipeToSessionRecipeVoMapper;
import com.calotter.cook.domain.SessionRoleToSessionRoleVoMapper;
import com.calotter.cook.domain.SessionToSessionVoMapper;
import com.calotter.cook.domain.bo.RecipeIngredientHistoryBoToRecipeIngredientHistoryMapper;
import com.calotter.cook.domain.bo.SessionBoToSessionMapper;
import com.calotter.cook.domain.bo.SessionRecipeBoToSessionRecipeMapper;
import com.calotter.cook.domain.bo.SessionRoleBoToSessionRoleMapper;
import com.calotter.cook.domain.vo.RecipeIngredientHistoryVoToRecipeIngredientHistoryMapper;
import com.calotter.cook.domain.vo.SessionRecipeVoToSessionRecipeMapper;
import com.calotter.cook.domain.vo.SessionRoleVoToSessionRoleMapper;
import com.calotter.cook.domain.vo.SessionVoToSessionMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__129.class, RecipeIngredientHistoryVoToRecipeIngredientHistoryMapper.class, SessionRoleVoToSessionRoleMapper.class, SessionRoleToSessionRoleVoMapper.class, SessionRecipeToSessionRecipeVoMapper.class, SessionRecipeVoToSessionRecipeMapper.class, RecipeIngredientHistoryToRecipeIngredientHistoryVoMapper.class, SessionVoToSessionMapper.class, SessionRecipeBoToSessionRecipeMapper.class, SessionToSessionVoMapper.class, SessionBoToSessionMapper.class, SessionRoleBoToSessionRoleMapper.class, RecipeIngredientHistoryBoToRecipeIngredientHistoryMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__129 {
}
