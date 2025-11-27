DROP TABLE IF EXISTS sous_chef_ums.users;
CREATE TABLE sous_chef_ums.users(
    id SERIAL NOT NULL,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(50),
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    status INT2 DEFAULT 1,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.users.id IS 'User id;User ID (PK)';
COMMENT ON COLUMN sous_chef_ums.users.username IS 'User name;Username (for login function)';
COMMENT ON COLUMN sous_chef_ums.users.email IS 'User email;Registration email (for login, receiving notification, and retrieving password)';
COMMENT ON COLUMN sous_chef_ums.users.password_hash IS 'Encrypted password;The hash value of user password, avoid saving plain text';
COMMENT ON COLUMN sous_chef_ums.users.display_name IS 'Name for display;Display name (e.g., Cooker Allen)';
COMMENT ON COLUMN sous_chef_ums.users.avatar_url IS 'URL of avatar;Avatar (optional)';
COMMENT ON COLUMN sous_chef_ums.users.created_at IS 'Created time;Registration time';
COMMENT ON COLUMN sous_chef_ums.users.updated_at IS 'Updated time;Update time';
COMMENT ON COLUMN sous_chef_ums.users.last_login_at IS 'User last login time;Last login time';
COMMENT ON COLUMN sous_chef_ums.users.status IS 'The status of user account;Account status: [0 - Disable, 1 - Enable]';
COMMENT ON TABLE sous_chef_ums.users IS 'users;User table of Sous Chef';

CREATE  UNIQUE INDEX uk_users_username ON sous_chef_ums.users (
    username ASC
);
COMMENT ON INDEX sous_chef_ums.uk_users_username IS 'Unique index of username;The unique index of username field in users table';
CREATE  UNIQUE INDEX uk_users_email ON sous_chef_ums.users (
    email ASC
);
COMMENT ON INDEX sous_chef_ums.uk_users_email IS 'Unique index of email;The unique index of email field in users table';