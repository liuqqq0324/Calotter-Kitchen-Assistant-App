package org.dromara.demo.domain;

import javax.annotation.processing.Generated;
import org.dromara.demo.domain.vo.TestDemoVo;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T16:50:02+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 25.0.1 (Homebrew)"
)
@Component
public class TestDemoToTestDemoVoMapperImpl implements TestDemoToTestDemoVoMapper {

    @Override
    public TestDemoVo convert(TestDemo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        TestDemoVo testDemoVo = new TestDemoVo();

        testDemoVo.setId( arg0.getId() );
        testDemoVo.setDeptId( arg0.getDeptId() );
        testDemoVo.setUserId( arg0.getUserId() );
        testDemoVo.setOrderNum( arg0.getOrderNum() );
        testDemoVo.setTestKey( arg0.getTestKey() );
        testDemoVo.setValue( arg0.getValue() );
        testDemoVo.setCreateTime( arg0.getCreateTime() );
        testDemoVo.setCreateBy( arg0.getCreateBy() );
        testDemoVo.setUpdateTime( arg0.getUpdateTime() );
        testDemoVo.setUpdateBy( arg0.getUpdateBy() );
        testDemoVo.setVersion( arg0.getVersion() );

        return testDemoVo;
    }

    @Override
    public TestDemoVo convert(TestDemo arg0, TestDemoVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setDeptId( arg0.getDeptId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setOrderNum( arg0.getOrderNum() );
        arg1.setTestKey( arg0.getTestKey() );
        arg1.setValue( arg0.getValue() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setVersion( arg0.getVersion() );

        return arg1;
    }
}
