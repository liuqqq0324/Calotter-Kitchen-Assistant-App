package org.dromara.workflow.domain;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.vo.FlowSpelVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:41+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowSpelToFlowSpelVoMapper__2Impl implements FlowSpelToFlowSpelVoMapper__2 {

    @Override
    public FlowSpelVo convert(FlowSpel arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowSpelVo flowSpelVo = new FlowSpelVo();

        flowSpelVo.setComponentName( arg0.getComponentName() );
        flowSpelVo.setCreateTime( arg0.getCreateTime() );
        flowSpelVo.setId( arg0.getId() );
        flowSpelVo.setMethodName( arg0.getMethodName() );
        flowSpelVo.setMethodParams( arg0.getMethodParams() );
        flowSpelVo.setRemark( arg0.getRemark() );
        flowSpelVo.setStatus( arg0.getStatus() );
        flowSpelVo.setViewSpel( arg0.getViewSpel() );

        return flowSpelVo;
    }

    @Override
    public FlowSpelVo convert(FlowSpel arg0, FlowSpelVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setComponentName( arg0.getComponentName() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setId( arg0.getId() );
        arg1.setMethodName( arg0.getMethodName() );
        arg1.setMethodParams( arg0.getMethodParams() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setViewSpel( arg0.getViewSpel() );

        return arg1;
    }
}
