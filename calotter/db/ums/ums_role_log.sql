DROP TABLE IF EXISTS sous_chef_ums.ums_role_log;
CREATE TABLE sous_chef_ums.ums_role_log(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    record_at DATE,
    weight_kg DECIMAL(5,2),
    height_cm INT2,
    notes TEXT,
    create_time TIMESTAMP,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_log.id IS 'Record id;Record ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.role_id IS 'Role id;Role ID (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.record_at IS 'Creation date;The creation date of this record';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.weight_kg IS 'Role weight;The weight of the role (unit: kg)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.height_cm IS 'Role height;The height of the role (unit: cm)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.notes IS 'Note;Note of the record (e.g., on an empty stomach or after dinner)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_log IS 'ums_role_log;Stores body metrics of user roles.';

CREATE INDEX gk_role_log_role_id ON sous_chef_ums.ums_role_log (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_log_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';