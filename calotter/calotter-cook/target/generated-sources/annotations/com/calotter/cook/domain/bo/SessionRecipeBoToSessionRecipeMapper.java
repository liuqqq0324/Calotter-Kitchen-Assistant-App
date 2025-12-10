package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.SessionRecipe;
import io.github.linpeilie.AutoMapperConfig__49;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__49.class,
    uses = {},
    imports = {}
)
public interface SessionRecipeBoToSessionRecipeMapper extends BaseMapper<SessionRecipeBo, SessionRecipe> {
}
