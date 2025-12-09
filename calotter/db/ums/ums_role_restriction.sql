DROP TABLE IF EXISTS sous_chef_ums.ums_role_restriction;
CREATE TABLE sous_chef_ums.ums_role_restriction(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    restriction_id INT8 NOT NULL,
    type INT2 DEFAULT 1,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.id IS 'Role restriction id;Role restriction ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.role_id IS 'Role id;Role id (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.restriction_id IS 'Restriction id;Restriction id (FK, restriction_id -> restriction.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.type IS 'Restriction type;Restriction type: [1-allergic, 2-taboo]';
COMMENT ON TABLE sous_chef_ums.ums_role_restriction IS 'ums_role_restriction;The dietary restrictions of specific dining role';

CREATE INDEX gk_role_restriction_role_id ON sous_chef_ums.ums_role_restriction (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_restriction_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';
CREATE INDEX gk_role_restriction_restriction_id ON sous_chef_ums.ums_role_restriction (
    restriction_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_restriction_restriction_id IS 'General index of restriction id;The general index of restriction_id FK to id in restriction table';