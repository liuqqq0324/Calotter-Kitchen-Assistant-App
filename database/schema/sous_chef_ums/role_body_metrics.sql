DROP TABLE IF EXISTS sous_chef_ums.role_body_metrics;
CREATE TABLE sous_chef_ums.role_body_metrics(
    id SERIAL NOT NULL,
    role_id INT8 NOT NULL,
    record_at DATE,
    weight_kg DECIMAL(5,2),
    height_cm INT2,
    notes TEXT,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.role_body_metrics.id IS 'Record id;Record ID (PK)';
COMMENT ON COLUMN sous_chef_ums.role_body_metrics.role_id IS 'Role id;Role ID (FK, role_id -> user_roles.id)';
COMMENT ON COLUMN sous_chef_ums.role_body_metrics.record_at IS 'Creation date;The creation date of this record';
COMMENT ON COLUMN sous_chef_ums.role_body_metrics.weight_kg IS 'Role weight;The weight of the role (unit: kg)';
COMMENT ON COLUMN sous_chef_ums.role_body_metrics.height_cm IS 'Role height;The height of the role (unit: cm)';
COMMENT ON COLUMN sous_chef_ums.role_body_metrics.notes IS 'Note;Note of the record (e.g., "on an empty stomach" or "after dinner")';
COMMENT ON TABLE sous_chef_ums.role_body_metrics IS 'role_body_metrics;Stores body metrics of a role';

CREATE INDEX gk_role_body_metrics_role_id ON sous_chef_ums.role_body_metrics (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_body_metrics_role_id IS 'General index of role id;The general index of role_id FK to id in user_roles table';