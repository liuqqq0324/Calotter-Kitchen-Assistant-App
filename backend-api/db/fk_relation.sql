/** ================================= CMS ================================= **/





ALTER TABLE sous_chef_cms.cms_recipe_ingredient_history
    ADD CONSTRAINT fk_recipe_ingredient_history_recipe
        FOREIGN KEY (recipe_id)
        REFERENCES sous_chef_cms.cms_session (id);

ALTER TABLE sous_chef_cms.cms_recipe_ingredient_history
    ADD CONSTRAINT fk_recipe_ingredient_history_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES sous_chef_rms.rms_ingredient (id);



ALTER TABLE sous_chef_cms.cms_session_recipe
    ADD CONSTRAINT fk_session_recipe_session
        FOREIGN KEY (session_id)
        REFERENCES sous_chef_cms.cms_session (id);

ALTER TABLE sous_chef_cms.cms_session_recipe
    ADD CONSTRAINT fk_session_recipe_recipe
        FOREIGN KEY (recipe_id)
        REFERENCES sous_chef_rms.rms_recipe (id);



ALTER TABLE sous_chef_cms.cms_session_role
    ADD CONSTRAINT fk_session_role_session
        FOREIGN KEY (session_id)
        REFERENCES sous_chef_cms.cms_session (id);

ALTER TABLE sous_chef_cms.cms_session_role
    ADD CONSTRAINT fk_session_role_role
        FOREIGN KEY (role_id)
        REFERENCES sous_chef_ums.ums_user_role (id);



ALTER TABLE sous_chef_cms.cms_session
    ADD CONSTRAINT fk_session_user
        FOREIGN KEY (user_id)
        REFERENCES sous_chef_ums.ums_user (id);






/** ================================= IMS ================================= **/





ALTER TABLE sous_chef_ims.ims_user_ingredient
    ADD CONSTRAINT fk_user_ingredient_user
        FOREIGN KEY (user_id)
        REFERENCES sous_chef_ums.ums_user (id);

ALTER TABLE sous_chef_ims.ims_user_ingredient
    ADD CONSTRAINT fk_user_ingredient_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES sous_chef_rms.rms_ingredient (id);



ALTER TABLE sous_chef_ims.ims_user_kitchenware
    ADD CONSTRAINT fk_user_kitchenware_user
        FOREIGN KEY (user_id)
        REFERENCES sous_chef_ums.ums_user (id);

ALTER TABLE sous_chef_ims.ims_user_kitchenware
    ADD CONSTRAINT fk_user_kitchenware_kitchenware
        FOREIGN KEY (kitchenware_id)
        REFERENCES sous_chef_rms.rms_kitchenware (id);





/** ================================= RMS ================================= **/





ALTER TABLE sous_chef_rms.rms_recipe_ingredient
    ADD CONSTRAINT fk_recipe_ingredient_recipe
        FOREIGN KEY (recipe_id)
        REFERENCES sous_chef_rms.rms_recipe (id);

ALTER TABLE sous_chef_rms.rms_recipe_ingredient
    ADD CONSTRAINT fk_recipe_ingredient_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES sous_chef_rms.rms_ingredient (id);



ALTER TABLE sous_chef_rms.rms_recipe_kitchenware
    ADD CONSTRAINT fk_recipe_kitchenware_recipe
        FOREIGN KEY (recipe_id)
        REFERENCES sous_chef_rms.rms_recipe (id);

ALTER TABLE sous_chef_rms.rms_recipe_kitchenware
    ADD CONSTRAINT fk_recipe_kitchenware_kitchenware
        FOREIGN KEY (kitchenware_id)
        REFERENCES sous_chef_rms.rms_kitchenware (id);





/** ================================= UMS ================================= **/





ALTER TABLE sous_chef_ums.ums_role_cuisine
    ADD CONSTRAINT fk_role_cuisine_role
        FOREIGN KEY (role_id)
        REFERENCES sous_chef_ums.ums_user_role (id);

ALTER TABLE sous_chef_ums.ums_role_cuisine
    ADD CONSTRAINT fk_role_cuisine_cuisine
        FOREIGN KEY (cuisine_id)
        REFERENCES sous_chef_rms.rms_cuisine_type (id);



ALTER TABLE sous_chef_ums.ums_role_log
    ADD CONSTRAINT fk_role_log_role
        FOREIGN KEY (role_id)
        REFERENCES sous_chef_ums.ums_user_role (id);



ALTER TABLE sous_chef_ums.ums_role_preference
    ADD CONSTRAINT fk_role_preference_role
        FOREIGN KEY (role_id)
        REFERENCES sous_chef_ums.ums_user_role (id);

ALTER TABLE sous_chef_ums.ums_role_preference
    ADD CONSTRAINT fk_role_preference_preference
        FOREIGN KEY (preference_id)
        REFERENCES sous_chef_ums.ums_preference (id);



ALTER TABLE sous_chef_ums.ums_role_restriction
    ADD CONSTRAINT fk_role_restriction_role
        FOREIGN KEY (role_id)
        REFERENCES sous_chef_ums.ums_user_role (id);

ALTER TABLE sous_chef_ums.ums_role_restriction
    ADD CONSTRAINT fk_role_restriction_restriction
        FOREIGN KEY (restriction_id)
        REFERENCES sous_chef_ums.ums_restriction (id);



ALTER TABLE sous_chef_ums.ums_user_role
    ADD CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id)
        REFERENCES sous_chef_ums.ums_user (id);