package com.calotter.user.domain;

import com.calotter.user.domain.bo.RestrictionBoToRestrictionMapper;
import com.calotter.user.domain.vo.RestrictionVo;
import com.calotter.user.domain.vo.RestrictionVoToRestrictionMapper;
import io.github.linpeilie.AutoMapperConfig__151;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__151.class,
    uses = {RestrictionVoToRestrictionMapper.class,RestrictionBoToRestrictionMapper.class},
    imports = {}
)
public interface RestrictionToRestrictionVoMapper extends BaseMapper<Restriction, RestrictionVo> {
}
