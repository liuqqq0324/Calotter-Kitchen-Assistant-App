package com.calotter.cook.domain;

import com.calotter.cook.domain.bo.SessionRecipeBoToSessionRecipeMapper;
import com.calotter.cook.domain.vo.SessionRecipeVo;
import com.calotter.cook.domain.vo.SessionRecipeVoToSessionRecipeMapper;
import io.github.linpeilie.AutoMapperConfig__148;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__148.class,
    uses = {SessionRecipeBoToSessionRecipeMapper.class,SessionRecipeVoToSessionRecipeMapper.class},
    imports = {}
)
public interface SessionRecipeToSessionRecipeVoMapper extends BaseMapper<SessionRecipe, SessionRecipeVo> {
}
