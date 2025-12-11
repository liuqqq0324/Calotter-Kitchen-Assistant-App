package com.calotter.user.domain;

import com.calotter.user.domain.bo.PreferenceBoToPreferenceMapper;
import com.calotter.user.domain.vo.PreferenceVo;
import com.calotter.user.domain.vo.PreferenceVoToPreferenceMapper;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {PreferenceVoToPreferenceMapper.class,PreferenceBoToPreferenceMapper.class},
    imports = {}
)
public interface PreferenceToPreferenceVoMapper extends BaseMapper<Preference, PreferenceVo> {
}
