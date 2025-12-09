DROP TABLE IF EXISTS sous_chef_cms.cms_session_role;
CREATE TABLE sous_chef_cms.cms_session_role(
    id BIGSERIAL NOT NULL,
    session_id INT8 NOT NULL,
    role_id INT8 NOT NULL,
    feedback_score INT2,
    feedback_desc TEXT,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_session_role.id IS 'Session role id;Session role ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.session_id IS 'Session record id;Session record ID (FK, session_id -> session.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.role_id IS 'Role id;Role ID (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.feedback_score IS 'Feedback score;Feedback score (optional): [0 - not specified, 1 - Unsatisfied, 2 - Somewhat unsatisfied, 3 - Neutral, 4 - Somewhat satisfied, 5 - satisfied]';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.feedback_desc IS 'Feedback text;Feedback description from the role (optional)';
COMMENT ON TABLE sous_chef_cms.cms_session_role IS 'cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.';

CREATE INDEX gk_session_role_session_id ON sous_chef_cms.cms_session_role (
    session_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_role_session_id IS 'General index of history id;The general index of session_id FK to id in session table';
CREATE INDEX gk_session_role_role_id ON sous_chef_cms.cms_session_role (
    role_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_role_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';