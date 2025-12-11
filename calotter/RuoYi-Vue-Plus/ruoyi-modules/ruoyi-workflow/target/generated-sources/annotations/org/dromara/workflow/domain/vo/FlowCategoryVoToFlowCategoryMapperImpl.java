package org.dromara.workflow.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.FlowCategory;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:12+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class FlowCategoryVoToFlowCategoryMapperImpl implements FlowCategoryVoToFlowCategoryMapper {

    @Override
    public FlowCategory convert(FlowCategoryVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowCategory flowCategory = new FlowCategory();

        flowCategory.setCreateTime( arg0.getCreateTime() );
        flowCategory.setCategoryId( arg0.getCategoryId() );
        flowCategory.setParentId( arg0.getParentId() );
        flowCategory.setAncestors( arg0.getAncestors() );
        flowCategory.setCategoryName( arg0.getCategoryName() );
        flowCategory.setOrderNum( arg0.getOrderNum() );

        return flowCategory;
    }

    @Override
    public FlowCategory convert(FlowCategoryVo arg0, FlowCategory arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setCategoryId( arg0.getCategoryId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setAncestors( arg0.getAncestors() );
        arg1.setCategoryName( arg0.getCategoryName() );
        arg1.setOrderNum( arg0.getOrderNum() );

        return arg1;
    }
}
