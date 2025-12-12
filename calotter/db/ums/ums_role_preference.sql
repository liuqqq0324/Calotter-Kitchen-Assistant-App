DROP TABLE IF EXISTS sous_chef_ums.ums_role_preference;
CREATE TABLE sous_chef_ums.ums_role_preference(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    preference_id INT8 NOT NULL,
    level INT2 DEFAULT 1,
    create_time TIMESTAMP,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.id IS 'Role preference id;Role preference ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.role_id IS 'Role id;Role id (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.preference_id IS 'Preference id;Preference id (FK, preference_id -> preference.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.level IS 'Preference level;Preference level: [1-like, 2-favorite]';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_preference IS 'ums_role_preference;The dietary preference of specific dining role';

CREATE INDEX gk_role_preference_role_id ON sous_chef_ums.ums_role_preference (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_preference_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';
CREATE INDEX gk_role_preference_preference_id ON sous_chef_ums.ums_role_preference (
    preference_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_preference_preference_id IS 'General index of preference id;The general index of preference_id FK to id in preference table';