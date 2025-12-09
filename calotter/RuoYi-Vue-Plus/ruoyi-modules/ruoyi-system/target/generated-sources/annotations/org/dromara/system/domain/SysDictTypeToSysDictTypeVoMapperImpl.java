package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysDictTypeVo;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:14+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysDictTypeToSysDictTypeVoMapperImpl implements SysDictTypeToSysDictTypeVoMapper {

    @Override
    public SysDictTypeVo convert(SysDictType arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDictTypeVo sysDictTypeVo = new SysDictTypeVo();

        sysDictTypeVo.setCreateTime( arg0.getCreateTime() );
        sysDictTypeVo.setDictId( arg0.getDictId() );
        sysDictTypeVo.setDictName( arg0.getDictName() );
        sysDictTypeVo.setDictType( arg0.getDictType() );
        sysDictTypeVo.setRemark( arg0.getRemark() );

        return sysDictTypeVo;
    }

    @Override
    public SysDictTypeVo convert(SysDictType arg0, SysDictTypeVo arg1) {
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
