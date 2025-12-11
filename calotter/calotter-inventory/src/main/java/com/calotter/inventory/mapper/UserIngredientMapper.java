package com.calotter.inventory.mapper;

import com.calotter.inventory.domain.UserIngredient;
import com.calotter.inventory.domain.vo.UserIngredientVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface UserIngredientMapper extends BaseMapperPlus<UserIngredient, UserIngredientVo> {

}
