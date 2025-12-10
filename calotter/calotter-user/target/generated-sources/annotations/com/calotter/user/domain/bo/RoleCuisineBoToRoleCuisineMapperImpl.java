package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleCuisine;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-10T15:10:17+1300",
    comments = "version: 1.6.3, compiler: Eclipse JDT (IDE) 3.44.0.v20251118-1623, environment: Java 21.0.9 (Eclipse Adoptium)"
)
@Component
public class RoleCuisineBoToRoleCuisineMapperImpl implements RoleCuisineBoToRoleCuisineMapper {

    @Override
    public RoleCuisine convert(RoleCuisineBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleCuisine roleCuisine = new RoleCuisine();

        roleCuisine.setCreateBy( arg0.getCreateBy() );
        roleCuisine.setCreateDept( arg0.getCreateDept() );
        roleCuisine.setCreateTime( arg0.getCreateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            roleCuisine.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        roleCuisine.setSearchValue( arg0.getSearchValue() );
        roleCuisine.setUpdateBy( arg0.getUpdateBy() );
        roleCuisine.setUpdateTime( arg0.getUpdateTime() );
        roleCuisine.setCuisineId( arg0.getCuisineId() );
        roleCuisine.setDescription( arg0.getDescription() );
        roleCuisine.setId( arg0.getId() );
        roleCuisine.setRoleId( arg0.getRoleId() );
        roleCuisine.setType( arg0.getType() );

        return roleCuisine;
    }

    @Override
    public RoleCuisine convert(RoleCuisineBo arg0, RoleCuisine arg1) {
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
        arg1.setCuisineId( arg0.getCuisineId() );
        arg1.setDescription( arg0.getDescription() );
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setType( arg0.getType() );

        return arg1;
    }
}
