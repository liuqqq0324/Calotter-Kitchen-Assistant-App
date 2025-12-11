package org.dromara.demo.domain.vo;

import javax.annotation.processing.Generated;
import org.dromara.demo.domain.TestTree;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T11:31:50+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class TestTreeVoToTestTreeMapper__2Impl implements TestTreeVoToTestTreeMapper__2 {

    @Override
    public TestTree convert(TestTreeVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestTree testTree = new TestTree();

        testTree.setCreateTime( arg0.getCreateTime() );
        testTree.setId( arg0.getId() );
        testTree.setParentId( arg0.getParentId() );
        testTree.setDeptId( arg0.getDeptId() );
        testTree.setUserId( arg0.getUserId() );
        testTree.setTreeName( arg0.getTreeName() );

        return testTree;
    }

    @Override
    public TestTree convert(TestTreeVo arg0, TestTree arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setId( arg0.getId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setTreeName( arg0.getTreeName() );

        return arg1;
    }
}
