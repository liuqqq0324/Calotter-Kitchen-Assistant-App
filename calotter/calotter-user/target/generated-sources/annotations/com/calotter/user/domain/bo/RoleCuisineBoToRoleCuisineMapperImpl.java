package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleCuisine;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-12-11T14:28:56+1300",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.8 (JetBrains s.r.o.)"
)
@Component
public class RoleCuisineBoToRoleCuisineMapperImpl implements RoleCuisineBoToRoleCuisineMapper {

    @Override
    public RoleCuisine convert(RoleCuisineBo arg0) {
        if ( arg0 == null ) {
            return null;
        }

        RoleCuisine roleCuisine = new RoleCuisine();

        roleCuisine.setSearchValue( arg0.getSearchValue() );
        roleCuisine.setCreateDept( arg0.getCreateDept() );
        roleCuisine.setCreateBy( arg0.getCreateBy() );
        roleCuisine.setCreateTime( arg0.getCreateTime() );
        roleCuisine.setUpdateBy( arg0.getUpdateBy() );
        roleCuisine.setUpdateTime( arg0.getUpdateTime() );
        Map<String, Object> map = arg0.getParams();
        if ( map != null ) {
            roleCuisine.setParams( new LinkedHashMap<String, Object>( map ) );
        }
        roleCuisine.setId( arg0.getId() );
        roleCuisine.setRoleId( arg0.getRoleId() );
        roleCuisine.setCuisineId( arg0.getCuisineId() );
        roleCuisine.setType( arg0.getType() );
        roleCuisine.setDescription( arg0.getDescription() );

        return roleCuisine;
    }

    @Override
    public RoleCuisine convert(RoleCuisineBo arg0, RoleCuisine arg1) {
        if ( arg0 == null ) {
            return arg1;
        }

        arg1.setSearchValue( arg0.getSearchValue() );
        arg1.setCreateDept( arg0.getCreateDept() );
        arg1.setCreateBy( arg0.getCreateBy() );
        arg1.setCreateTime( arg0.getCreateTime() );
        arg1.setUpdateBy( arg0.getUpdateBy() );
        arg1.setUpdateTime( arg0.getUpdateTime() );
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
        arg1.setId( arg0.getId() );
        arg1.setRoleId( arg0.getRoleId() );
        arg1.setCuisineId( arg0.getCuisineId() );
        arg1.setType( arg0.getType() );
        arg1.setDescription( arg0.getDescription() );

        return arg1;
    }
}
