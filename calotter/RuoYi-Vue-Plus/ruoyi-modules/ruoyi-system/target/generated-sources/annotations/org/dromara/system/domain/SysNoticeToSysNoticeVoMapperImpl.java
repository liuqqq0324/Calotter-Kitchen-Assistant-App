package org.dromara.system.domain;

import javax.annotation.processing.Generated;
import org.dromara.system.domain.vo.SysNoticeVo;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T17:59:11+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
public class SysNoticeToSysNoticeVoMapperImpl implements SysNoticeToSysNoticeVoMapper {

    @Override
    public SysNoticeVo convert(SysNotice arg0) {
        if ( arg0 == null ) {
            return null;
        }

        SysNoticeVo sysNoticeVo = new SysNoticeVo();

        sysNoticeVo.setNoticeId( arg0.getNoticeId() );
        sysNoticeVo.setNoticeTitle( arg0.getNoticeTitle() );
        sysNoticeVo.setNoticeType( arg0.getNoticeType() );
        sysNoticeVo.setNoticeContent( arg0.getNoticeContent() );
        sysNoticeVo.setStatus( arg0.getStatus() );
        sysNoticeVo.setRemark( arg0.getRemark() );
        sysNoticeVo.setCreateBy( arg0.getCreateBy() );
        sysNoticeVo.setCreateTime( arg0.getCreateTime() );

        return sysNoticeVo;
    }

    @Override
    public SysNoticeVo convert(SysNotice arg0, SysNoticeVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setNoticeId( arg0.getNoticeId() );
        arg1.setNoticeTitle( arg0.getNoticeTitle() );
        arg1.setNoticeType( arg0.getNoticeType() );
        arg1.setNoticeContent( arg0.getNoticeContent() );
        arg1.setStatus( arg0.getStatus() );
        arg1.setRemark( arg0.getRemark() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );

        return arg1;
    }
}
