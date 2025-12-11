package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysDictType;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T13:27:22+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysDictTypeVoToSysDictTypeMapperImpl implements SysDictTypeVoToSysDictTypeMapper {

    @Override
    public SysDictType convert(SysDictTypeVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDictType sysDictType = new SysDictType();

        sysDictType.setCreateTime( arg0.getCreateTime() );
        sysDictType.setDictId( arg0.getDictId() );
        sysDictType.setDictName( arg0.getDictName() );
        sysDictType.setDictType( arg0.getDictType() );
        sysDictType.setRemark( arg0.getRemark() );

        return sysDictType;
    }

    @Override
    public SysDictType convert(SysDictTypeVo arg0, SysDictType arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setDictId( arg0.getDictId() );
        arg1.setDictName( arg0.getDictName() );
        arg1.setDictType( arg0.getDictType() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
