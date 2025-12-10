package org.dromara.workflow.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.FlowSpel;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:43+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowSpelBoToFlowSpelMapperImpl implements FlowSpelBoToFlowSpelMapper {

    @Override
    public FlowSpel convert(FlowSpelBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowSpel flowSpel = new FlowSpel();

        flowSpel.setCreateBy( arg0.getCreateBy() );
        flowSpel.setCreateDept( arg0.getCreateDept() );
        flowSpel.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            flowSpel.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        flowSpel.setSearchValue( arg0.getSearchValue() );
        flowSpel.setUpdateBy( arg0.getUpdateBy() );
        flowSpel.setUpdateTime( arg0.getUpdateTime() );
        flowSpel.setComponentName( arg0.getComponentName() );
        flowSpel.setId( arg0.getId() );
        flowSpel.setMethodName( arg0.getMethodName() );
        flowSpel.setMethodParams( arg0.getMethodParams() );
        flowSpel.setRemark( arg0.getRemark() );
        flowSpel.setStatus( arg0.getStatus() );
        flowSpel.setViewSpel( arg0.getViewSpel() );

        return flowSpel;
    }

    @Override
    public FlowSpel convert(FlowSpelBo arg0, FlowSpel arg1) {
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
        arg1.setComponentName( arg0.getComponentName() );
        arg1.setId( arg0.getId() );
        arg1.setMethodName( arg0.getMethodName() );
        arg1.setMethodParams( arg0.getMethodParams() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setViewSpel( arg0.getViewSpel() );

        return arg1;
    }
}
