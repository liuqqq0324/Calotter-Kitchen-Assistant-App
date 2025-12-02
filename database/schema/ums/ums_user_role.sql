DROP TABLE IF EXISTS sous_chef_ums.ums_user_role;
CREATE TABLE sous_chef_ums.ums_user_role(
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
COMMENT ON COLUMN sous_chef_ums.ums_user_role.id IS 'Role id;Role ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.user_id IS 'User id;User ID (FK, user_id -> user.id)';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.name IS 'Role name;Role name (e.g., "grandpa", "daughter", "friend A")';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.account_owner IS 'Account owner;Whether this role is the account owner';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.preferences IS 'Dietary preferences;The dietary preference of the role, stored as a JSONB format. (e.g., {"name": "beef", "level": "favorite"}';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.taboos IS 'Dietary taboos;The dietary taboos of the role, stored as a JSONB format. (e.g., {"name": "cilantro", "level": "unacceptable"}';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.allergies IS 'Food allergies;The food allergies of the role, stored as a JSONB format. (e.g., {"allergies": ["eggplant", "peanut"]}';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.gender IS 'Gender;Role gender: [0 - Unknown, 1 - Male, 2 - Female]';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.birthdate IS 'Birthdate;The birthdate of user role';
COMMENT ON TABLE sous_chef_ums.ums_user_role IS 'ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.';

CREATE INDEX gk_user_roles_user_id ON sous_chef_ums.ums_user_role (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_roles_user_id IS 'General index of user id;The general index of user_id FK to id in user table';