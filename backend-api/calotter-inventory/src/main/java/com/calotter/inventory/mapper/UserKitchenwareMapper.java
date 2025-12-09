package com.calotter.inventory.mapper;

import com.calotter.inventory.domain.UserKitchenware;
import com.calotter.inventory.domain.vo.UserKitchenwareVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface UserKitchenwareMapper extends BaseMapperPlus<UserKitchenware, UserKitchenwareVo> {

}
