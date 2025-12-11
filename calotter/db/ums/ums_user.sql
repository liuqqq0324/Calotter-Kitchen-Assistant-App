DROP TABLE IF EXISTS sous_chef_ums.ums_user;
CREATE TABLE sous_chef_ums.ums_user(
    id BIGSERIAL NOT NULL,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(50),
    avatar_url VARCHAR(255),
    age INTEGER,
    height INTEGER,
    weight INTEGER,
    gender VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    status INT2 DEFAULT 1,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_user.id IS 'User id;User ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_user.username IS 'User name;Username (for login function)';
COMMENT ON COLUMN sous_chef_ums.ums_user.email IS 'User email;Registration email (for login, receiving notifications, and retrieving password)';
COMMENT ON COLUMN sous_chef_ums.ums_user.password_hash IS 'Encrypted password;The hash value of user password, avoid saving plain text';
COMMENT ON COLUMN sous_chef_ums.ums_user.display_name IS 'Name for display;Display name (e.g., Cooker Allen)';
COMMENT ON COLUMN sous_chef_ums.ums_user.avatar_url IS 'URL of avatar;Avatar (optional)';
COMMENT ON COLUMN sous_chef_ums.ums_user.age IS 'User age;User age in years';
COMMENT ON COLUMN sous_chef_ums.ums_user.height IS 'User height;User height in cm';
COMMENT ON COLUMN sous_chef_ums.ums_user.weight IS 'User weight;User weight in kg';
COMMENT ON COLUMN sous_chef_ums.ums_user.gender IS 'User gender;User gender (e.g., male, female, other)';
COMMENT ON COLUMN sous_chef_ums.ums_user.created_at IS 'Created time;Registration time';
COMMENT ON COLUMN sous_chef_ums.ums_user.updated_at IS 'Updated time;Update time';
COMMENT ON COLUMN sous_chef_ums.ums_user.last_login_at IS 'User last login time;Last login time';
COMMENT ON COLUMN sous_chef_ums.ums_user.status IS 'The status of user account;Account status: [0 - Disable, 1 - Enable]';
COMMENT ON TABLE sous_chef_ums.ums_user IS 'ums_user;This table is the master user table, storing the basic information of all users.';

CREATE  UNIQUE INDEX uk_user_username ON sous_chef_ums.ums_user (
    username ASC
);
COMMENT ON INDEX sous_chef_ums.uk_user_username IS 'Unique index of username;The unique index of username field in user table';
CREATE  UNIQUE INDEX uk_user_email ON sous_chef_ums.ums_user (
    email ASC
);
COMMENT ON INDEX sous_chef_ums.uk_user_email IS 'Unique index of email;The unique index of email field in user table';