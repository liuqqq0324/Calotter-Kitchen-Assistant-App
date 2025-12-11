package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.SessionRecipe;
import com.calotter.cook.domain.SessionRecipeToSessionRecipeVoMapper;
import io.github.linpeilie.AutoMapperConfig__129;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__129.class,
    uses = {SessionRecipeToSessionRecipeVoMapper.class},
    imports = {}
)
public interface SessionRecipeVoToSessionRecipeMapper extends BaseMapper<SessionRecipeVo, SessionRecipe> {
}
