DROP TABLE IF EXISTS sous_chef_ums.user_roles;
CREATE TABLE sous_chef_ums.user_roles(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    name VARCHAR(50) NOT NULL,
    account_owner BOOLEAN DEFAULT FALSE,
    preferences JSONB,
    taboos JSONB,
    allergies JSONB,
    gender INT2 DEFAULT 0,
    birthdate DATE,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.user_roles.id IS 'Role id;Role ID (PK)';
COMMENT ON COLUMN sous_chef_ums.user_roles.user_id IS 'User id;User ID (FK, user_id -> users.id)';
COMMENT ON COLUMN sous_chef_ums.user_roles.name IS 'Role name;Role name (e.g., "grandpa", "daughter", "friend A")';
COMMENT ON COLUMN sous_chef_ums.user_roles.account_owner IS 'Account owner;Whether this role is the account owner';
COMMENT ON COLUMN sous_chef_ums.user_roles.preferences IS 'Dietary preferences;The dietary preference of the role, stored as a JSONB format. (e.g., {"name": "beef", "level": "favorite"}';
COMMENT ON COLUMN sous_chef_ums.user_roles.taboos IS 'Dietary taboos;The dietary taboos of the role, stored as a JSONB format. (e.g., {"name": "cilantro", "level": "unacceptable"}';
COMMENT ON COLUMN sous_chef_ums.user_roles.allergies IS 'Food allergies;The food allergies of the role, stored as a JSONB format. (e.g., {"allergies": ["eggplant", "peanut"]}';
COMMENT ON COLUMN sous_chef_ums.user_roles.gender IS 'Gender;Role gender: [0 - Unknown, 1 - Male, 2 - Female]';
COMMENT ON COLUMN sous_chef_ums.user_roles.birthdate IS 'Birthdate;The birthdate of user role';
COMMENT ON TABLE sous_chef_ums.user_roles IS 'user_roles;The roles of user account';

CREATE INDEX gk_user_roles_user_id ON sous_chef_ums.user_roles (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_roles_user_id IS 'General index of user id;The general index of user_id FK to id in users table';