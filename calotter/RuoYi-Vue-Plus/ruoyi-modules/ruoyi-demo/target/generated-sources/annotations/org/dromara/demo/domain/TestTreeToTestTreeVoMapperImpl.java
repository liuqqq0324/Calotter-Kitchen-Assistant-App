package org.dromara.demo.domain;

import javax.annotation.processing.Generated;
import org.dromara.demo.domain.vo.TestTreeVo;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:10+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class TestTreeToTestTreeVoMapperImpl implements TestTreeToTestTreeVoMapper {

    @Override
    public TestTreeVo convert(TestTree arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestTreeVo testTreeVo = new TestTreeVo();

        testTreeVo.setId( arg0.getId() );
        testTreeVo.setParentId( arg0.getParentId() );
        testTreeVo.setDeptId( arg0.getDeptId() );
        testTreeVo.setUserId( arg0.getUserId() );
        testTreeVo.setTreeName( arg0.getTreeName() );
        testTreeVo.setCreateTime( arg0.getCreateTime() );

        return testTreeVo;
    }

    @Override
    public TestTreeVo convert(TestTree arg0, TestTreeVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setParentId( arg0.getParentId() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setTreeName( arg0.getTreeName() );
        arg1.setCreateTime( arg0.getCreateTime() );

        return arg1;
    }
}
