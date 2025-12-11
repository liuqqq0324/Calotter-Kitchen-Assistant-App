package org.dromara.workflow.domain;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.vo.FlowSpelVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:50:03+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class FlowSpelToFlowSpelVoMapperImpl implements FlowSpelToFlowSpelVoMapper {

    @Override
    public FlowSpelVo convert(FlowSpel arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowSpelVo flowSpelVo = new FlowSpelVo();

        flowSpelVo.setId( arg0.getId() );
        flowSpelVo.setComponentName( arg0.getComponentName() );
        flowSpelVo.setMethodName( arg0.getMethodName() );
        flowSpelVo.setMethodParams( arg0.getMethodParams() );
        flowSpelVo.setViewSpel( arg0.getViewSpel() );
        flowSpelVo.setStatus( arg0.getStatus() );
        flowSpelVo.setRemark( arg0.getRemark() );
        flowSpelVo.setCreateTime( arg0.getCreateTime() );

        return flowSpelVo;
    }

    @Override
    public FlowSpelVo convert(FlowSpel arg0, FlowSpelVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setComponentName( arg0.getComponentName() );
        arg1.setMethodName( arg0.getMethodName() );
        arg1.setMethodParams( arg0.getMethodParams() );
        arg1.setViewSpel( arg0.getViewSpel() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setCreateTime( arg0.getCreateTime() );

        return arg1;
    }
}
