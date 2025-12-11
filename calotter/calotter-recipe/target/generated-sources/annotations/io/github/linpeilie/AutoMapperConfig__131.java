package io.github.linpeilie;

import com.calotter.recipe.domain.CuisineTypeToCuisineTypeVoMapper;
import com.calotter.recipe.domain.IngredientToIngredientVoMapper;
import com.calotter.recipe.domain.KitchenwareToKitchenwareVoMapper;
import com.calotter.recipe.domain.RecipeIngredientToRecipeIngredientVoMapper;
import com.calotter.recipe.domain.RecipeKitchenwareToRecipeKitchenwareVoMapper;
import com.calotter.recipe.domain.RecipeToRecipeVoMapper;
import com.calotter.recipe.domain.bo.CuisineTypeBoToCuisineTypeMapper;
import com.calotter.recipe.domain.bo.IngredientBoToIngredientMapper;
import com.calotter.recipe.domain.bo.KitchenwareBoToKitchenwareMapper;
import com.calotter.recipe.domain.bo.RecipeBoToRecipeMapper;
import com.calotter.recipe.domain.bo.RecipeIngredientBoToRecipeIngredientMapper;
import com.calotter.recipe.domain.bo.RecipeKitchenwareBoToRecipeKitchenwareMapper;
import com.calotter.recipe.domain.vo.CuisineTypeVoToCuisineTypeMapper;
import com.calotter.recipe.domain.vo.IngredientVoToIngredientMapper;
import com.calotter.recipe.domain.vo.KitchenwareVoToKitchenwareMapper;
import com.calotter.recipe.domain.vo.RecipeIngredientVoToRecipeIngredientMapper;
import com.calotter.recipe.domain.vo.RecipeKitchenwareVoToRecipeKitchenwareMapper;
import com.calotter.recipe.domain.vo.RecipeVoToRecipeMapper;
import org.mapstruct.Builder;
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;

@MapperConfig(
    componentModel = "spring-lazy",
    uses = {ConverterMapperAdapter__131.class, RecipeKitchenwareVoToRecipeKitchenwareMapper.class, KitchenwareVoToKitchenwareMapper.class, IngredientBoToIngredientMapper.class, IngredientToIngredientVoMapper.class, IngredientVoToIngredientMapper.class, RecipeToRecipeVoMapper.class, RecipeIngredientToRecipeIngredientVoMapper.class, CuisineTypeBoToCuisineTypeMapper.class, RecipeKitchenwareToRecipeKitchenwareVoMapper.class, RecipeVoToRecipeMapper.class, RecipeIngredientVoToRecipeIngredientMapper.class, RecipeBoToRecipeMapper.class, KitchenwareToKitchenwareVoMapper.class, RecipeKitchenwareBoToRecipeKitchenwareMapper.class, RecipeIngredientBoToRecipeIngredientMapper.class, CuisineTypeVoToCuisineTypeMapper.class, CuisineTypeToCuisineTypeVoMapper.class, KitchenwareBoToKitchenwareMapper.class},
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    builder = @Builder(buildMethod = "build", disableBuilder = true)
)
public interface AutoMapperConfig__131 {
}
