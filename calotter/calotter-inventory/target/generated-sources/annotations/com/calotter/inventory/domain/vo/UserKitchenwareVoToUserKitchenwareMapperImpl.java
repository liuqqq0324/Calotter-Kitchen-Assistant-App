package com.calotter.inventory.domain.vo;

import com.calotter.inventory.domain.UserKitchenware;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:29:57+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserKitchenwareVoToUserKitchenwareMapperImpl implements UserKitchenwareVoToUserKitchenwareMapper {

    @Override
    public UserKitchenware convert(UserKitchenwareVo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserKitchenware userKitchenware = new UserKitchenware();

        userKitchenware.setId( arg0.getId() );
        userKitchenware.setUserId( arg0.getUserId() );
        userKitchenware.setKitchenwareId( arg0.getKitchenwareId() );
        userKitchenware.setNickname( arg0.getNickname() );
        userKitchenware.setPurchaseDate( arg0.getPurchaseDate() );
        userKitchenware.setConditionStatus( arg0.getConditionStatus() );

        return userKitchenware;
    }

    @Override
    public UserKitchenware convert(UserKitchenwareVo arg0, UserKitchenware arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setId( arg0.getId() );
        arg1.setUserId( arg0.getUserId() );
        arg1.setKitchenwareId( arg0.getKitchenwareId() );
        arg1.setNickname( arg0.getNickname() );
        arg1.setPurchaseDate( arg0.getPurchaseDate() );
        arg1.setConditionStatus( arg0.getConditionStatus() );

        return arg1;
    }
}
