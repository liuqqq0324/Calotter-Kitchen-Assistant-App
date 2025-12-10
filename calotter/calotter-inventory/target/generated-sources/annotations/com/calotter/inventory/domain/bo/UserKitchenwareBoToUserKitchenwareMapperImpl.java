package com.calotter.inventory.domain.bo;

import com.calotter.inventory.domain.UserKitchenware;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:13+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class UserKitchenwareBoToUserKitchenwareMapperImpl implements UserKitchenwareBoToUserKitchenwareMapper {

    @Override
    public UserKitchenware convert(UserKitchenwareBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        UserKitchenware userKitchenware = new UserKitchenware();

        userKitchenware.setSearchValue( arg0.getSearchValue() );
        userKitchenware.setCreateDept( arg0.getCreateDept() );
        userKitchenware.setCreateBy( arg0.getCreateBy() );
        userKitchenware.setCreateTime( arg0.getCreateTime() );
        userKitchenware.setUpdateBy( arg0.getUpdateBy() );
        userKitchenware.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            userKitchenware.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        userKitchenware.setConditionStatus( arg0.getConditionStatus() );
        userKitchenware.setId( arg0.getId() );
        userKitchenware.setKitchenwareId( arg0.getKitchenwareId() );
        userKitchenware.setNickname( arg0.getNickname() );
        userKitchenware.setPurchaseDate( arg0.getPurchaseDate() );
        userKitchenware.setUserId( arg0.getUserId() );

        return userKitchenware;
    }

    @Override
    public UserKitchenware convert(UserKitchenwareBo arg0, UserKitchenware arg1) {
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
        arg1.setConditionStatus( arg0.getConditionStatus() );
        arg1.setId( arg0.getId() );
        arg1.setKitchenwareId( arg0.getKitchenwareId() );
        arg1.setNickname( arg0.getNickname() );
        arg1.setPurchaseDate( arg0.getPurchaseDate() );
        arg1.setUserId( arg0.getUserId() );

        return arg1;
    }
}
