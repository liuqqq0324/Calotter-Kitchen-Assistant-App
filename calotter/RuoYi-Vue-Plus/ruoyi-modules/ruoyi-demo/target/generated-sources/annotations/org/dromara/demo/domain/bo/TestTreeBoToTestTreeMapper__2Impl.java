package org.dromara.demo.domain.bo;

import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.dromara.demo.domain.TestTree;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:27+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class TestTreeBoToTestTreeMapper__2Impl implements TestTreeBoToTestTreeMapper__2 {

    @Override
    public TestTree convert(TestTreeBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestTree testTree = new TestTree();

        testTree.setCreateBy( arg0.getCreateBy() );
        testTree.setCreateDept( arg0.getCreateDept() );
        testTree.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            testTree.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        testTree.setSearchValue( arg0.getSearchValue() );
        testTree.setUpdateBy( arg0.getUpdateBy() );
        testTree.setUpdateTime( arg0.getUpdateTime() );
        testTree.setDeptId( arg0.getDeptId() );
        testTree.setId( arg0.getId() );
        testTree.setParentId( arg0.getParentId() );
        testTree.setTreeName( arg0.getTreeName() );
        testTree.setUserId( arg0.getUserId() );

        return testTree;
    }

    @Override
    public TestTree convert(TestTreeBo arg0, TestTree arg1) {
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
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setId( arg0.getId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setTreeName( arg0.getTreeName() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
