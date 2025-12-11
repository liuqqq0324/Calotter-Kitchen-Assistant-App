package com.calotter.user.domain.vo;

import com.calotter.user.domain.Preference;
import com.calotter.user.domain.PreferenceToPreferenceVoMapper;
import io.github.linpeilie.AutoMapperConfig__226;
import io.github.linpeilie.BaseMapper;
import org.mapstruct.Mapper;

@Mapper(
    config = AutoMapperConfig__226.class,
    uses = {PreferenceToPreferenceVoMapper.class},
    imports = {}
)
public interface PreferenceVoToPreferenceMapper extends BaseMapper<PreferenceVo, Preference> {
}
