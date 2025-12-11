package org.dromara.workflow.domain;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.vo.FlowCategoryVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:30:41+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowCategoryToFlowCategoryVoMapper__2Impl implements FlowCategoryToFlowCategoryVoMapper__2 {

    @Override
    public FlowCategoryVo convert(FlowCategory arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowCategoryVo flowCategoryVo = new FlowCategoryVo();

        flowCategoryVo.setAncestors( arg0.getAncestors() );
        flowCategoryVo.setCategoryId( arg0.getCategoryId() );
        flowCategoryVo.setCategoryName( arg0.getCategoryName() );
        flowCategoryVo.setCreateTime( arg0.getCreateTime() );
        flowCategoryVo.setOrderNum( arg0.getOrderNum() );
        flowCategoryVo.setParentId( arg0.getParentId() );

        return flowCategoryVo;
    }

    @Override
    public FlowCategoryVo convert(FlowCategory arg0, FlowCategoryVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setAncestors( arg0.getAncestors() );
        arg1.setCategoryId( arg0.getCategoryId() );
        arg1.setCategoryName( arg0.getCategoryName() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setParentId( arg0.getParentId() );

        return arg1;
    }
}
