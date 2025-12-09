package org.dromara.workflow.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.FlowCategory;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:28+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowCategoryVoToFlowCategoryMapperImpl implements FlowCategoryVoToFlowCategoryMapper {

    @Override
    public FlowCategory convert(FlowCategoryVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowCategory flowCategory = new FlowCategory();

        flowCategory.setCreateTime( arg0.getCreateTime() );
        flowCategory.setAncestors( arg0.getAncestors() );
        flowCategory.setCategoryId( arg0.getCategoryId() );
        flowCategory.setCategoryName( arg0.getCategoryName() );
        flowCategory.setOrderNum( arg0.getOrderNum() );
        flowCategory.setParentId( arg0.getParentId() );

        return flowCategory;
    }

    @Override
    public FlowCategory convert(FlowCategoryVo arg0, FlowCategory arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setAncestors( arg0.getAncestors() );
        arg1.setCategoryId( arg0.getCategoryId() );
        arg1.setCategoryName( arg0.getCategoryName() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setParentId( arg0.getParentId() );

        return arg1;
    }
}
