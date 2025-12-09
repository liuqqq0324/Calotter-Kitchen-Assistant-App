package org.dromara.demo.domain;

import javax.annotation.processing.Generated;
import org.dromara.demo.domain.vo.TestTreeVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T12:23:05+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class TestTreeToTestTreeVoMapper__2Impl implements TestTreeToTestTreeVoMapper__2 {

    @Override
    public TestTreeVo convert(TestTree arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestTreeVo testTreeVo = new TestTreeVo();

        testTreeVo.setCreateTime( arg0.getCreateTime() );
        testTreeVo.setDeptId( arg0.getDeptId() );
        testTreeVo.setId( arg0.getId() );
        testTreeVo.setParentId( arg0.getParentId() );
        testTreeVo.setTreeName( arg0.getTreeName() );
        testTreeVo.setUserId( arg0.getUserId() );

        return testTreeVo;
    }

    @Override
    public TestTreeVo convert(TestTree arg0, TestTreeVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setId( arg0.getId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setTreeName( arg0.getTreeName() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
