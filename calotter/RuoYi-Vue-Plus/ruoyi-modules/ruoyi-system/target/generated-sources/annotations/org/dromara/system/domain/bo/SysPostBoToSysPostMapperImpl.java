package org.dromara.system.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.system.domain.SysPost;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:10+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysPostBoToSysPostMapperImpl implements SysPostBoToSysPostMapper {

    @Override
    public SysPost convert(SysPostBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysPost sysPost = new SysPost();

        sysPost.setCreateBy( arg0.getCreateBy() );
        sysPost.setCreateDept( arg0.getCreateDept() );
        sysPost.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            sysPost.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        sysPost.setSearchValue( arg0.getSearchValue() );
        sysPost.setUpdateBy( arg0.getUpdateBy() );
        sysPost.setUpdateTime( arg0.getUpdateTime() );
        sysPost.setPostId( arg0.getPostId() );
        sysPost.setDeptId( arg0.getDeptId() );
        sysPost.setPostCode( arg0.getPostCode() );
        sysPost.setPostName( arg0.getPostName() );
        sysPost.setPostCategory( arg0.getPostCategory() );
        sysPost.setPostSort( arg0.getPostSort() );
        sysPost.setStatus( arg0.getStatus() );
        sysPost.setRemark( arg0.getRemark() );

        return sysPost;
    }

    @Override
    public SysPost convert(SysPostBo arg0, SysPost arg1) {
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
        arg1.setPostId( arg0.getPostId() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setPostCode( arg0.getPostCode() );
        arg1.setPostName( arg0.getPostName() );
        arg1.setPostCategory( arg0.getPostCategory() );
        arg1.setPostSort( arg0.getPostSort() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setRemark( arg0.getRemark() );

        return arg1;
    }
}
