package org.dromara.workflow.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.FlowSpel;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:30+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowSpelVoToFlowSpelMapperImpl implements FlowSpelVoToFlowSpelMapper {

    @Override
    public FlowSpel convert(FlowSpelVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowSpel flowSpel = new FlowSpel();

        flowSpel.setCreateTime( arg0.getCreateTime() );
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
    public FlowSpel convert(FlowSpelVo arg0, FlowSpel arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
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
