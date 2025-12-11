package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysDictData;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:49:58+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class SysDictDataBoToSysDictDataMapperImpl implements SysDictDataBoToSysDictDataMapper {

    @Override
    public SysDictData convert(SysDictDataBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysDictData sysDictData = new SysDictData();

        sysDictData.setSearchValue( arg0.getSearchValue() );
        sysDictData.setCreateDept( arg0.getCreateDept() );
        sysDictData.setCreateBy( arg0.getCreateBy() );
        sysDictData.setCreateTime( arg0.getCreateTime() );
        sysDictData.setUpdateBy( arg0.getUpdateBy() );
        sysDictData.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysDictData.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysDictData.setDictCode( arg0.getDictCode() );
        sysDictData.setDictSort( arg0.getDictSort() );
        sysDictData.setDictLabel( arg0.getDictLabel() );
        sysDictData.setDictValue( arg0.getDictValue() );
        sysDictData.setDictType( arg0.getDictType() );
        sysDictData.setCssClass( arg0.getCssClass() );
        sysDictData.setListClass( arg0.getListClass() );
        sysDictData.setIsDefault( arg0.getIsDefault() );
        sysDictData.setRemark( arg0.getRemark() );

        return sysDictData;
    }

    @Override
    public SysDictData convert(SysDictDataBo arg0, SysDictData arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
        arg1.setDictCode( arg0.getDictCode() );
        arg1.setDictSort( arg0.getDictSort() );
        arg1.setDictLabel( arg0.getDictLabel() );
        arg1.setDictValue( arg0.getDictValue() );
        arg1.setDictType( arg0.getDictType() );
        arg1.setCssClass( arg0.getCssClass() );
        arg1.setListClass( arg0.getListClass() );
        arg1.setIsDefault( arg0.getIsDefault() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
