DROP TABLE IF EXISTS sous_chef_ums.ums_role_cuisine;
CREATE TABLE sous_chef_ums.ums_role_cuisine(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    cuisine_id INT8 NOT NULL,
    type INT2 NOT NULL DEFAULT 1,
    description TEXT,
    create_time TIMESTAMP,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.id IS 'Role cuisine id;Role cuisine ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.role_id IS 'Role id;Role ID (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.cuisine_id IS 'Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.type IS 'Type of association;Association type: [1-like, 2-dislike]';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.description IS 'Description;Association description (e.g., like to eat Sichuan Dishes for lunch)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_cuisine IS 'ums_role_cuisine;The association table of dining role and cuisine';

CREATE INDEX gk_role_cuisine_role_id ON sous_chef_ums.ums_role_cuisine (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_cuisine_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';
CREATE INDEX gk_role_cuisine_cuisine_id ON sous_chef_ums.ums_role_cuisine (
    cuisine_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_cuisine_cuisine_id IS 'General index of cuisine id;The general index of cuisine_id FK to id in cuisine_type table';