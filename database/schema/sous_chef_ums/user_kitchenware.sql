DROP TABLE IF EXISTS sous_chef_ums.user_kitchenware;
CREATE TABLE sous_chef_ums.user_kitchenware(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    kitchenware_id INT8 NOT NULL,
    nickname VARCHAR,
    purchase_date VARCHAR,
    condition_status VARCHAR(20),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.user_kitchenware.id IS 'User kitchenware id;User kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_ums.user_kitchenware.user_id IS 'User id;Refer to the owner's user id (FK, user_id -> users.id)';
COMMENT ON COLUMN sous_chef_ums.user_kitchenware.kitchenware_id IS 'Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenwares.id)';
COMMENT ON COLUMN sous_chef_ums.user_kitchenware.nickname IS 'Nickname;Nickname that user made to the kitchenware (e.g., "My Frying Pan")';
COMMENT ON COLUMN sous_chef_ums.user_kitchenware.purchase_date IS 'Date of purchase;When the kitchenware is purchased';
COMMENT ON COLUMN sous_chef_ums.user_kitchenware.condition_status IS 'Condition status;The status of the kitchenware (e.g., "NEW", "USED", "BROKEN")';
COMMENT ON TABLE sous_chef_ums.user_kitchenware IS 'user_kitchenware;Stores the kitchenware';

CREATE INDEX gk_user_kitchenware_user_id ON sous_chef_ums.user_kitchenware (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_kitchenware_user_id IS 'General index of user id;The general index of user_id FK to id in users table';
CREATE INDEX gk_user_kitchenware_kitchenware_id ON sous_chef_ums.user_kitchenware (
    kitchenware_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_kitchenware_kitchenware_id IS 'General index of kitchenware id;The general index of kitchenware_id FK to id in kitchenwares table';
