package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysDictData;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:36+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class SysDictDataBoToSysDictDataMapperImpl implements SysDictDataBoToSysDictDataMapper {

    @Override
    public SysDictData convert(SysDictDataBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDictData sysDictData = new SysDictData();

        sysDictData.setCreateBy( arg0.getCreateBy() );
        sysDictData.setCreateDept( arg0.getCreateDept() );
        sysDictData.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysDictData.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysDictData.setSearchValue( arg0.getSearchValue() );
        sysDictData.setUpdateBy( arg0.getUpdateBy() );
        sysDictData.setUpdateTime( arg0.getUpdateTime() );
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
    public SysDictData convert(SysDictDataBo arg0, SysDictData arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateTime( arg0.getCreateTime() );
        if ( arg1.getParams() != null ) {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.getParams().clear();
                arg1.getParams().putAll( map );
            }
            else {
                arg1.setParams( null );
            }
        }
        else {
            Map<String, Object> map = arg0.getParams();
            if ( map != null ) {
                arg1.setParams( new LinkedHashMap<String, Object>( map ) );
            }
        }
        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
