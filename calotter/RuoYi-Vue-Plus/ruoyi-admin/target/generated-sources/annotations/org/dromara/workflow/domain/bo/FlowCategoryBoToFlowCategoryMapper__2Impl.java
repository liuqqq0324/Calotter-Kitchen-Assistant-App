package org.dromara.workflow.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.workflow.domain.FlowCategory;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:58:12+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class FlowCategoryBoToFlowCategoryMapper__2Impl implements FlowCategoryBoToFlowCategoryMapper__2 {

    @Override
    public FlowCategory convert(FlowCategoryBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        FlowCategory flowCategory = new FlowCategory();

        flowCategory.setCreateBy( arg0.getCreateBy() );
        flowCategory.setCreateDept( arg0.getCreateDept() );
        flowCategory.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            flowCategory.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        flowCategory.setSearchValue( arg0.getSearchValue() );
        flowCategory.setUpdateBy( arg0.getUpdateBy() );
        flowCategory.setUpdateTime( arg0.getUpdateTime() );
        flowCategory.setCategoryId( arg0.getCategoryId() );
        flowCategory.setParentId( arg0.getParentId() );
        flowCategory.setCategoryName( arg0.getCategoryName() );
        flowCategory.setOrderNum( arg0.getOrderNum() );

        return flowCategory;
    }

    @Override
    public FlowCategory convert(FlowCategoryBo arg0, FlowCategory arg1) {
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
        arg1.setCategoryId( arg0.getCategoryId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setCategoryName( arg0.getCategoryName() );
        arg1.setOrderNum( arg0.getOrderNum() );

        return arg1;
    }
}
