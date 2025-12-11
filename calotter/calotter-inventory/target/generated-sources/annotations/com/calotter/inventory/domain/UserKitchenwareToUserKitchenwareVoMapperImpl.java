package com.calotter.inventory.domain;

import com.calotter.inventory.domain.vo.UserKitchenwareVo;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T13:57:46+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserKitchenwareToUserKitchenwareVoMapperImpl implements UserKitchenwareToUserKitchenwareVoMapper {

    @Override
    public UserKitchenwareVo convert(UserKitchenware arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserKitchenwareVo userKitchenwareVo = new UserKitchenwareVo();

        userKitchenwareVo.setConditionStatus( arg0.getConditionStatus() );
        userKitchenwareVo.setId( arg0.getId() );
        userKitchenwareVo.setKitchenwareId( arg0.getKitchenwareId() );
        userKitchenwareVo.setNickname( arg0.getNickname() );
        userKitchenwareVo.setPurchaseDate( arg0.getPurchaseDate() );
        userKitchenwareVo.setUserId( arg0.getUserId() );

        return userKitchenwareVo;
    }

    @Override
    public UserKitchenwareVo convert(UserKitchenware arg0, UserKitchenwareVo arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setConditionStatus( arg0.getConditionStatus() );
        arg1.setId( arg0.getId() );
        arg1.setKitchenwareId( arg0.getKitchenwareId() );
        arg1.setNickname( arg0.getNickname() );
        arg1.setPurchaseDate( arg0.getPurchaseDate() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
