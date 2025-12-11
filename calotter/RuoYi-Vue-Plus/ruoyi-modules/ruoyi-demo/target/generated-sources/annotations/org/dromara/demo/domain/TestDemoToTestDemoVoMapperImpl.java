package org.dromara.demo.domain;

import javax.annotation.processing.Generated;
import org.dromara.demo.domain.vo.TestDemoVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:42:47+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class TestDemoToTestDemoVoMapperImpl implements TestDemoToTestDemoVoMapper {

    @Override
    public TestDemoVo convert(TestDemo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestDemoVo testDemoVo = new TestDemoVo();

        testDemoVo.setCreateBy( arg0.getCreateBy() );
        testDemoVo.setCreateTime( arg0.getCreateTime() );
        testDemoVo.setDeptId( arg0.getDeptId() );
        testDemoVo.setId( arg0.getId() );
        testDemoVo.setOrderNum( arg0.getOrderNum() );
        testDemoVo.setTestKey( arg0.getTestKey() );
        testDemoVo.setUpdateBy( arg0.getUpdateBy() );
        testDemoVo.setUpdateTime( arg0.getUpdateTime() );
        testDemoVo.setUserId( arg0.getUserId() );
        testDemoVo.setValue( arg0.getValue() );
        testDemoVo.setVersion( arg0.getVersion() );

        return testDemoVo;
    }

    @Override
    public TestDemoVo convert(TestDemo arg0, TestDemoVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setId( arg0.getId() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setTestKey( arg0.getTestKey() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setValue( arg0.getValue() );
        arg1.setVersion( arg0.getVersion() );

        return arg1;
    }
}
