package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysDictDataVo;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:10+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysDictDataToSysDictDataVoMapperImpl implements SysDictDataToSysDictDataVoMapper {

    @Override
    public SysDictDataVo convert(SysDictData arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDictDataVo sysDictDataVo = new SysDictDataVo();

        sysDictDataVo.setDictCode( arg0.getDictCode() );
        sysDictDataVo.setDictSort( arg0.getDictSort() );
        sysDictDataVo.setDictLabel( arg0.getDictLabel() );
        sysDictDataVo.setDictValue( arg0.getDictValue() );
        sysDictDataVo.setDictType( arg0.getDictType() );
        sysDictDataVo.setCssClass( arg0.getCssClass() );
        sysDictDataVo.setListClass( arg0.getListClass() );
        sysDictDataVo.setIsDefault( arg0.getIsDefault() );
        sysDictDataVo.setRemark( arg0.getRemark() );
        sysDictDataVo.setCreateTime( arg0.getCreateTime() );

        return sysDictDataVo;
    }

    @Override
    public SysDictDataVo convert(SysDictData arg0, SysDictDataVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setDictCode( arg0.getDictCode() );
        arg1.setDictSort( arg0.getDictSort() );
        arg1.setDictLabel( arg0.getDictLabel() );
        arg1.setDictValue( arg0.getDictValue() );
        arg1.setDictType( arg0.getDictType() );
        arg1.setCssClass( arg0.getCssClass() );
        arg1.setListClass( arg0.getListClass() );
        arg1.setIsDefault( arg0.getIsDefault() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setCreateTime( arg0.getCreateTime() );

        return arg1;
    }
}
