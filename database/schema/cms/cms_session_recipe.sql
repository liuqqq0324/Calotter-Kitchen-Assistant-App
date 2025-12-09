DROP TABLE IF EXISTS sous_chef_cms.cms_session_recipe;
CREATE TABLE sous_chef_cms.cms_session_recipe(
    id SERIAL NOT NULL,
    session_id INT8 NOT NULL,
    recipe_id INT8 NOT NULL,
    servings INT2,
    actual_duration_minutes INT2,
    success_rating INT2,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.id IS 'Cooking session recipe id;Cooking session recipe ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.session_id IS 'Cooking session id;Cooking history ID (FK, session_id -> session.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.recipe_id IS 'Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.servings IS 'Number of roles served;Number of people being served';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.actual_duration_minutes IS 'Time spend on this dish;The actual time spend on this dish';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.success_rating IS 'The success level rating;The success level rating (level: [1 ~ 5])';
COMMENT ON TABLE sous_chef_cms.cms_session_recipe IS 'cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.';

CREATE INDEX gk_session_recipe_session_id ON sous_chef_cms.cms_session_recipe (
    session_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_recipe_session_id IS 'General index of session id;The general index of session_id FK to id in session table';
CREATE INDEX gk_session_recipe_recipe_id ON sous_chef_cms.cms_session_recipe (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_recipe_recipe_id IS 'General index of recipe id;The general index of recipe_id FK to id in recipe table';