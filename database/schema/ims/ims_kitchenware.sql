DROP TABLE IF EXISTS sous_chef_ims.ims_kitchenware;
CREATE TABLE sous_chef_ims.ims_kitchenware(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    kitchenware_id INT8 NOT NULL,
    nickname VARCHAR,
    purchase_date VARCHAR,
    condition_status VARCHAR(20),
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ims.ims_kitchenware.id IS 'User kitchenware id;User kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_ims.ims_kitchenware.user_id IS 'User id;Refer to the account owner's user id (FK, user_id -> users.id)';
COMMENT ON COLUMN sous_chef_ims.ims_kitchenware.kitchenware_id IS 'Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenwares.id)';
COMMENT ON COLUMN sous_chef_ims.ims_kitchenware.nickname IS 'Nickname;Nickname that user made to the kitchenware (e.g., "My Frying Pan")';
COMMENT ON COLUMN sous_chef_ims.ims_kitchenware.purchase_date IS 'Date of purchase;When the kitchenware is purchased';
COMMENT ON COLUMN sous_chef_ims.ims_kitchenware.condition_status IS 'Condition status;The status of the kitchenware (e.g., "NEW", "USED", "BROKEN")';
COMMENT ON TABLE sous_chef_ims.ims_kitchenware IS 'ims_kitchenware;This table stores all users' kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.';

CREATE INDEX gk_user_kitchenware_user_id ON sous_chef_ims.ims_kitchenware (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_kitchenware_user_id IS 'General index of user id;The general index of user_id FK to id in user table';
CREATE INDEX gk_user_kitchenware_kitchenware_id ON sous_chef_ims.ims_kitchenware (
    kitchenware_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_kitchenware_kitchenware_id IS 'General index of kitchenware id;The general index of kitchenware_id FK to id in kitchenware table';