package org.dromara.system.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysDictData;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:03+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysDictDataVoToSysDictDataMapper__1Impl implements SysDictDataVoToSysDictDataMapper__1 {

    @Override
    public SysDictData convert(SysDictDataVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDictData sysDictData = new SysDictData();

        sysDictData.setCreateTime( arg0.getCreateTime() );
        sysDictData.setCssClass( arg0.getCssClass() );
        sysDictData.setDictCode( arg0.getDictCode() );
        sysDictData.setDictLabel( arg0.getDictLabel() );
        sysDictData.setDictSort( arg0.getDictSort() );
        sysDictData.setDictType( arg0.getDictType() );
        sysDictData.setDictValue( arg0.getDictValue() );
        sysDictData.setIsDefault( arg0.getIsDefault() );
        sysDictData.setListClass( arg0.getListClass() );
        sysDictData.setRemark( arg0.getRemark() );

        return sysDictData;
    }

    @Override
    public SysDictData convert(SysDictDataVo arg0, SysDictData arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setCssClass( arg0.getCssClass() );
        arg1.setDictCode( arg0.getDictCode() );
        arg1.setDictLabel( arg0.getDictLabel() );
        arg1.setDictSort( arg0.getDictSort() );
        arg1.setDictType( arg0.getDictType() );
        arg1.setDictValue( arg0.getDictValue() );
        arg1.setIsDefault( arg0.getIsDefault() );
        arg1.setListClass( arg0.getListClass() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
