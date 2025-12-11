package org.dromara.workflow.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.FlowSpel;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:50+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowSpelBoToFlowSpelMapper__2Impl implements FlowSpelBoToFlowSpelMapper__2 {

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
        flowSpel.setId( arg0.getId() );
        flowSpel.setComponentName( arg0.getComponentName() );
        flowSpel.setMethodName( arg0.getMethodName() );
        flowSpel.setMethodParams( arg0.getMethodParams() );
        flowSpel.setViewSpel( arg0.getViewSpel() );
        flowSpel.setStatus( arg0.getStatus() );
        flowSpel.setRemark( arg0.getRemark() );

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
        arg1.setId( arg0.getId() );
        arg1.setComponentName( arg0.getComponentName() );
        arg1.setMethodName( arg0.getMethodName() );
        arg1.setMethodParams( arg0.getMethodParams() );
        arg1.setViewSpel( arg0.getViewSpel() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
