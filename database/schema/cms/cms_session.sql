DROP TABLE IF EXISTS sous_chef_cms.cms_session;
CREATE TABLE sous_chef_cms.cms_session(
    id SERIAL NOT NULL,
    user_id INT8 NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    meal_type INT2 DEFAULT 0,
    note TEXT,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_session.id IS 'Cooking history id;Cooking history ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_session.user_id IS 'User id;Who performed this cooking (FK, user_id -> users.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session.start_time IS 'Start time;Cooking start time';
COMMENT ON COLUMN sous_chef_cms.cms_session.end_time IS 'End time;Cooking end time';
COMMENT ON COLUMN sous_chef_cms.cms_session.meal_type IS 'Meal type;Meal type: [0 - other / unknown, 1 - breakfast, 2 - lunch, 3 - dinner, 4 - midnight snack, 5 - snack]';
COMMENT ON COLUMN sous_chef_cms.cms_session.note IS 'Overall note;Overall note (e.g., "for mom birthday celebration"';
COMMENT ON TABLE sous_chef_cms.cms_session IS 'cms_session;This table records the start and end times for all user cooking sessions, along with which meal they prepared.';

CREATE INDEX gk_cooking_history_user_id ON sous_chef_cms.cms_session (
    user_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_cooking_history_user_id IS 'General index of user id;The general index of user_id FK to id in user table';