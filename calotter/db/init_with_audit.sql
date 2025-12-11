/** ==================================================== CMS ==================================================== **/

DROP TABLE IF EXISTS sous_chef_cms.cms_recipe_ingredient_history;
CREATE TABLE sous_chef_cms.cms_recipe_ingredient_history(
    id BIGSERIAL NOT NULL,
    recipe_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity_used DECIMAL(10,2),
    unit VARCHAR(20),
    substitution BOOLEAN DEFAULT FALSE,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.id IS 'Session ingredient usage id;Session ingredient usage ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.recipe_id IS 'Recipe id;History recipe ID (FK, recipe_id -> session.id)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.ingredient_id IS 'Ingredient id;Ingredient ID (FK, ingredient_id -> ingredient.id)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.quantity_used IS 'Quantity used;Quantity used for the dish';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.unit IS 'Unit of ingredient used;Unit for the used ingredient';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.substitution IS 'Is a substitution ingredient;Whether is a substitution ingredient (e.g., the recipe is beef, but I used pork)';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_cms.cms_recipe_ingredient_history.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_cms.cms_recipe_ingredient_history IS 'cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.';

CREATE INDEX gk_recipe_ingredient_history_recipe_id ON sous_chef_cms.cms_recipe_ingredient_history (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_recipe_ingredient_history_recipe_id IS 'General index of history dish id;The general index of recipe_id FK to id in recipe table';
CREATE INDEX gk_recipe_ingredient_history_ingredient_id ON sous_chef_cms.cms_recipe_ingredient_history (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_recipe_ingredient_history_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';


DROP TABLE IF EXISTS sous_chef_cms.cms_session_recipe;
CREATE TABLE sous_chef_cms.cms_session_recipe(
    id BIGSERIAL NOT NULL,
    session_id INT8 NOT NULL,
    recipe_id INT8 NOT NULL,
    servings INT2,
    actual_duration_minutes INT2,
    success_rating INT2,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.id IS 'Session recipe id;Cooking session recipe ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.session_id IS 'Session id;Cooking history ID (FK, session_id -> session.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.recipe_id IS 'Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.servings IS 'Number of roles served;Number of people that is able to serve';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.actual_duration_minutes IS 'Time spend on this dish;The actual time spend on this dish';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.success_rating IS 'The success level rating;The success level rating (level: [1 ~ 5])';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_cms.cms_session_recipe.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_cms.cms_session_recipe IS 'cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.';

CREATE INDEX gk_session_recipe_session_id ON sous_chef_cms.cms_session_recipe (
    session_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_recipe_session_id IS 'General index of session id;The general index of session_id FK to id in session table';
CREATE INDEX gk_session_recipe_recipe_id ON sous_chef_cms.cms_session_recipe (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_recipe_recipe_id IS 'General index of recipe id;The general index of recipe_id FK to id in recipe table';


DROP TABLE IF EXISTS sous_chef_cms.cms_session_role;
CREATE TABLE sous_chef_cms.cms_session_role(
    id BIGSERIAL NOT NULL,
    session_id INT8 NOT NULL,
    role_id INT8 NOT NULL,
    feedback_score INT2,
    feedback_desc TEXT,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_session_role.id IS 'Session role id;Session role ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.session_id IS 'Session record id;Session record ID (FK, session_id -> session.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.role_id IS 'Role id;Role ID (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.feedback_score IS 'Feedback score;Feedback score (optional): [0 - not specified, 1 - Unsatisfied, 2 - Somewhat unsatisfied, 3 - Neutral, 4 - Somewhat satisfied, 5 - satisfied]';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.feedback_desc IS 'Feedback text;Feedback description from the role (optional)';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_cms.cms_session_role.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_cms.cms_session_role IS 'cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.';

CREATE INDEX gk_session_role_session_id ON sous_chef_cms.cms_session_role (
    session_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_role_session_id IS 'General index of history id;The general index of session_id FK to id in session table';
CREATE INDEX gk_session_role_role_id ON sous_chef_cms.cms_session_role (
    role_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_role_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';


DROP TABLE IF EXISTS sous_chef_cms.cms_session;
CREATE TABLE sous_chef_cms.cms_session(
    id BIGSERIAL NOT NULL,
    user_id INT8 NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    meal_type INT2 DEFAULT 0,
    note TEXT,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_cms.cms_session.id IS 'Cooking session id;Cooking history ID (PK)';
COMMENT ON COLUMN sous_chef_cms.cms_session.user_id IS 'User id;Who performed this cooking (FK, user_id -> user.id)';
COMMENT ON COLUMN sous_chef_cms.cms_session.start_time IS 'Start time;Cooking start time';
COMMENT ON COLUMN sous_chef_cms.cms_session.end_time IS 'End time;Cooking end time';
COMMENT ON COLUMN sous_chef_cms.cms_session.meal_type IS 'Meal type;Meal type: [0 - other / unknown, 1 - breakfast, 2 - lunch, 3 - dinner, 4 - midnight snack, 5 - snack]';
COMMENT ON COLUMN sous_chef_cms.cms_session.note IS 'Overall note;Overall note (e.g., to celebrate the birthday of mom)';
COMMENT ON COLUMN sous_chef_cms.cms_session.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_cms.cms_session.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_cms.cms_session.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_cms.cms_session.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_cms.cms_session.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_cms.cms_session IS 'cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.';

CREATE INDEX gk_session_user_id ON sous_chef_cms.cms_session (
    user_id ASC
);
COMMENT ON INDEX sous_chef_cms.gk_session_user_id IS 'General index of user id;The general index of user_id FK to id in user table';


/** ==================================================== IMS ==================================================== **/

DROP TABLE IF EXISTS sous_chef_ims.ims_user_ingredient;
CREATE TABLE sous_chef_ims.ims_user_ingredient(
    id BIGSERIAL NOT NULL,
    user_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity DECIMAL(10,2),
    current_unit VARCHAR(20),
    expiration_date DATE,
    storage_location VARCHAR(50),
    category_type VARCHAR(20),
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.id IS 'Pantry id;Pantry ID (PK)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.user_id IS 'User id;Whose pantry (FK, user_id -> user.id)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.ingredient_id IS 'Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.quantity IS 'Quantity;Quantity of the ingredient';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.current_unit IS 'Current unit;Current unit of the ingredient (e.g., g, ml, ea...)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.expiration_date IS 'Date of expiration;When the ingredient expires (for expiration display and reminder function)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.storage_location IS 'Location of storage;Where the ingredient stores (e.g., refrigerator, cabinetry)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.category_type IS 'Type of category;Redundant field or enumeration (e.g., INGREDIENT or CONDIMENT)';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ims.ims_user_ingredient.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ims.ims_user_ingredient IS 'ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.';

CREATE INDEX gk_user_pantry_user_id ON sous_chef_ims.ims_user_ingredient (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_pantry_user_id IS 'General index of user id;The general index of user_id FK to id in user table';
CREATE INDEX gk_user_pantry_ingredient_id ON sous_chef_ims.ims_user_ingredient (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_pantry_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';


DROP TABLE IF EXISTS sous_chef_ims.ims_user_kitchenware;
CREATE TABLE sous_chef_ims.ims_user_kitchenware(
    id BIGSERIAL NOT NULL,
    user_id INT8 NOT NULL,
    kitchenware_id INT8 NOT NULL,
    nickname VARCHAR,
    purchase_date VARCHAR,
    condition_status VARCHAR(20),
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.id IS 'User Kitchenware id;User kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.user_id IS 'User id;Refer to the account owner user id (FK, user_id -> user.id)';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.kitchenware_id IS 'Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenware.id)';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.nickname IS 'Nickname;Nickname that the user made for the kitchenware (e.g., My Frying Pan)';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.purchase_date IS 'Date of purchase;When the kitchenware is purchased';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.condition_status IS 'Condition status;The status of the kitchenware (e.g., NEW, USED, BROKEN)';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ims.ims_user_kitchenware.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ims.ims_user_kitchenware IS 'ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.';

CREATE INDEX gk_user_kitchenware_user_id ON sous_chef_ims.ims_user_kitchenware (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_kitchenware_user_id IS 'General index of user id;The general index of user_id FK to id in user table';
CREATE INDEX gk_user_kitchenware_kitchenware_id ON sous_chef_ims.ims_user_kitchenware (
    kitchenware_id ASC
);
COMMENT ON INDEX sous_chef_ims.gk_user_kitchenware_kitchenware_id IS 'General index of kitchenware id;The general index of kitchenware_id FK to id in kitchenware table';


/** ==================================================== RMS ==================================================== **/

DROP TABLE IF EXISTS sous_chef_rms.rms_cuisine_type;
CREATE TABLE sous_chef_rms.rms_cuisine_type(
    id BIGSERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    icon_url VARCHAR(255),
    sort INT2 DEFAULT 0,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.id IS 'Cuisine id;Cuisine ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.name IS 'Cuisine name;Cuisine name';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.icon_url IS 'Cuisine icon url;Icon URL of the cuisine';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.sort IS 'Sort priority;Sort the priority of the display sequence';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_rms.rms_cuisine_type.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_rms.rms_cuisine_type IS 'rms_cuisine_type;The cuisine types of recipes';

CREATE UNIQUE INDEX uk_cuisine_type_name ON sous_chef_rms.rms_cuisine_type (
    name ASC
);
COMMENT ON INDEX sous_chef_rms.uk_cuisine_type_name IS 'Unique index of name;The unique index of name field in cuisine type table';


DROP TABLE IF EXISTS sous_chef_rms.rms_ingredient;
CREATE TABLE sous_chef_rms.rms_ingredient(
    id BIGSERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    standard_unit VARCHAR(20),
    nutrition_info JSONB,
    storage_advice TEXT,
    image_url VARCHAR(255),
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.id IS 'Ingredient id;Ingredient ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.name IS 'Ingredient name;Ingredient name (e.g., tomato)';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.category IS 'Category;Ingredient category (e.g., vegetable)';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.standard_unit IS 'Standard unit;Standard unit (e.g., g)';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.nutrition_info IS 'Nutrition information;Nutrition value';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.storage_advice IS 'Advice for the ingredient storage;Storage advice (for AI assistant prompt, e.g., Store in the refrigerator or in a cool, dark place)';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.image_url IS 'Standard image;Standard image URL for ingredient image';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_rms.rms_ingredient.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_rms.rms_ingredient IS 'rms_ingredient;Stores all ingredients could be used in a recipe.';


DROP TABLE IF EXISTS sous_chef_rms.rms_kitchenware;
CREATE TABLE sous_chef_rms.rms_kitchenware(
    id BIGSERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    category VARCHAR(50),
    electronic BOOLEAN,
    default_shown BOOLEAN,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.id IS 'Kitchenware id;Kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.name IS 'Kitchenware name;Name of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.description IS 'Kitchenware description;Description of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.image_url IS 'Kitchenware image url;Image URL of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.category IS 'Kitchenware category;Category of the kitchenware';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.electronic IS 'Whether is electronic;Whether the kitchenware is electronic';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.default_shown IS 'Whether is shown by default;Whether the kitchenware is shown by default';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_rms.rms_kitchenware.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_rms.rms_kitchenware IS 'rms_kitchenware;Global kitchenware table';

CREATE UNIQUE INDEX uk_kitchenware_name ON sous_chef_rms.rms_kitchenware (
    name ASC
);
COMMENT ON INDEX sous_chef_rms.uk_kitchenware_name IS 'Unique index of kitchenware;The unique index of name field in kitchenware table';


DROP TABLE IF EXISTS sous_chef_rms.rms_recipe_ingredient;
CREATE TABLE sous_chef_rms.rms_recipe_ingredient(
    id BIGSERIAL NOT NULL,
    recipe_id INT8 NOT NULL,
    ingredient_id INT8 NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    processing_note VARCHAR(50),
    optional BOOLEAN DEFAULT FALSE,
    garnish BOOLEAN DEFAULT FALSE,
    sort INT2,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.id IS 'Recipe ingredient id;Recipe ingredient ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.recipe_id IS 'Recipe id;Recipe id (FK, recipe_id -> recipe.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.ingredient_id IS 'Ingredient id;Ingredient id (FK, ingredient_id -> ingredient.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.quantity IS 'Quantity of ingredient;Estimated quantity of ingredients used';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.unit IS 'Unit of ingredients;Unit of ingredients';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.processing_note IS 'Processing note;Processing note (e.g., cut into slices, remove skins)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.optional IS 'Is optional;Whether this ingredient is optional';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.garnish IS 'Is garnish;Whether this ingredient is garnish';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.sort IS 'Sort of process;Display order';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_ingredient.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_rms.rms_recipe_ingredient IS 'rms_recipe_ingredient;Store the ingredient compositions of recipes.';

CREATE INDEX gk_recipe_ingredient_recipe_id ON sous_chef_rms.rms_recipe_ingredient (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_ingredient_recipe_id IS 'General index of recipe id;The general index of recipe_id FK to id in recipe table';
CREATE INDEX gk_recipe_ingredient_ingredient_id ON sous_chef_rms.rms_recipe_ingredient (
    ingredient_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_ingredient_ingredient_id IS 'General index of ingredient id;The general index of ingredient_id FK to id in ingredient table';


DROP TABLE IF EXISTS sous_chef_rms.rms_recipe_kitchenware;
CREATE TABLE sous_chef_rms.rms_recipe_kitchenware(
    id BIGSERIAL NOT NULL,
    recipe_id INT8 NOT NULL,
    kitchenware_id INT8 NOT NULL,
    note VARCHAR(50),
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.id IS 'Recipe kitchenware id;Recipe kitchenware ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.recipe_id IS 'Recipe id;Recipe ID (FK, recipe_id -> recipe.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.kitchenware_id IS 'Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.note IS 'Note;Note (e.g., pre-heat to 200 degrees centigrade)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe_kitchenware.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_rms.rms_recipe_kitchenware IS 'rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.';

CREATE INDEX gk_recipe_kitchenware_recipe_id ON sous_chef_rms.rms_recipe_kitchenware (
    recipe_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_kitchenware_recipe_id IS 'General index of recipe id;The general index of recipe_id FK to id in recipe table';
CREATE INDEX gk_recipe_kitchenware_kitchenware_id ON sous_chef_rms.rms_recipe_kitchenware (
    kitchenware_id ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_kitchenware_kitchenware_id IS 'General index of kitchenware id;The general index of kitchenware_id FK to id in kitchenware table';


DROP TABLE IF EXISTS sous_chef_rms.rms_recipe;
CREATE TABLE sous_chef_rms.rms_recipe(
    id BIGSERIAL NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    cuisine_type VARCHAR(50),
    difficulty_level INT2 DEFAULT 1,
    serving_size INT2 DEFAULT 1,
    prep_time_minutes INT2,
    cook_time_minutes INT2,
    total_time_minutes INT2,
    calories_per_serving INT2,
    tags JSONB,
    instructions JSONB,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_rms.rms_recipe.id IS 'Recipe id;Recipe ID (PK)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.name IS 'Recipe name;Recipe name';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.description IS 'A brief description of recipe;Recipe description (e.g., scrambled eggs with tomatoes)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.image_url IS 'Finish product image url;URL of finished product image';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.cuisine_type IS 'The cuisine type of recipe;Cuisine type (e.g., Sichuan dishes, Italian noodles)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.difficulty_level IS 'The difficulty level;Difficulty of cooking: [1 - EZ, 2 - Medium, 3 - Hard]';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.serving_size IS 'The standard serving size;Standard serving size (e.g., for 2 people)';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.prep_time_minutes IS 'The time cost for preparation;The time cost of preparation process';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.cook_time_minutes IS 'The time cost for cooking;The time cost of cooking process';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.total_time_minutes IS 'The time cost in total;The time cost in total';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.calories_per_serving IS 'The estimated calories per one serving size;The estimated calories per one serving size';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.tags IS 'The tags of recipe;Tags of recipe';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.instructions IS 'The detailed steps for cooking;Cooking steps';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_rms.rms_recipe.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_rms.rms_recipe IS 'rms_recipe;Stores all recipes and the corresponding ingredients.';

CREATE INDEX gk_recipe_cuisine_type ON sous_chef_rms.rms_recipe (
    cuisine_type ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_cuisine_type IS 'Recipe cuisine type;Cuisine type general index';
CREATE INDEX gk_recipe_tags ON sous_chef_rms.rms_recipe (
    tags ASC
);
COMMENT ON INDEX sous_chef_rms.gk_recipe_tags IS 'Recipe tag;GIN supports searching specific tags';


/** ==================================================== UMS ==================================================== **/

DROP TABLE IF EXISTS sous_chef_ums.ums_preference;
CREATE TABLE sous_chef_ums.ums_preference(
    id BIGSERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    default_shown BOOLEAN,
    sort INT2 DEFAULT 0,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_preference.id IS 'Preference id;Preference ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_preference.name IS 'Preference name;Preference name';
COMMENT ON COLUMN sous_chef_ums.ums_preference.description IS 'Preference description;Preference description';
COMMENT ON COLUMN sous_chef_ums.ums_preference.default_shown IS 'Whether is shown by default;Whether the Preference is shown by default';
COMMENT ON COLUMN sous_chef_ums.ums_preference.sort IS 'Sort priority;Sort the priority of the display sequence';
COMMENT ON COLUMN sous_chef_ums.ums_preference.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_preference.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_preference.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_preference.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_preference.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_preference IS 'ums_preference;The global dietary preference of dining roles';

CREATE UNIQUE INDEX uk_preference_name ON sous_chef_ums.ums_preference (
    name ASC
);
COMMENT ON INDEX sous_chef_ums.uk_preference_name IS 'Unique index of name;The unique index of name field in preference table';


DROP TABLE IF EXISTS sous_chef_ums.ums_restriction;
CREATE TABLE sous_chef_ums.ums_restriction(
    id BIGSERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    default_shown BOOLEAN,
    sort INT2 DEFAULT 0,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_restriction.id IS 'Restriction id;Restriction ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.name IS 'Restriction name;Restriction name';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.description IS 'Restriction description;The description of the restriction';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.default_shown IS 'Whether is default shown;Whether the dietary restriction is shown by default';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.sort IS 'Sort priority;Sort the priority of the display sequence';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_restriction.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_restriction IS 'ums_restriction;The global dietary restrictions of dining roles';


DROP TABLE IF EXISTS sous_chef_ums.ums_role_cuisine;
CREATE TABLE sous_chef_ums.ums_role_cuisine(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    cuisine_id INT8 NOT NULL,
    type INT2 NOT NULL DEFAULT 1,
    description TEXT,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.id IS 'Role cuisine id;Role cuisine ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.role_id IS 'Role id;Role ID (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.cuisine_id IS 'Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.type IS 'Type of association;Association type: [1-like, 2-dislike]';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.description IS 'Description;Association description (e.g., like to eat Sichuan Dishes for lunch)';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_role_cuisine.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_cuisine IS 'ums_role_cuisine;The association table of dining role and cuisine';

CREATE INDEX gk_role_cuisine_role_id ON sous_chef_ums.ums_role_cuisine (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_cuisine_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';
CREATE INDEX gk_role_cuisine_cuisine_id ON sous_chef_ums.ums_role_cuisine (
    cuisine_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_cuisine_cuisine_id IS 'General index of cuisine id;The general index of cuisine_id FK to id in cuisine_type table';


DROP TABLE IF EXISTS sous_chef_ums.ums_role_log;
CREATE TABLE sous_chef_ums.ums_role_log(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    record_at DATE,
    weight_kg DECIMAL(5,2),
    height_cm INT2,
    notes TEXT,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_log.id IS 'Record id;Record ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.role_id IS 'Role id;Role ID (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.record_at IS 'Creation date;The creation date of this record';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.weight_kg IS 'Role weight;The weight of the role (unit: kg)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.height_cm IS 'Role height;The height of the role (unit: cm)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.notes IS 'Note;Note of the record (e.g., on an empty stomach or after dinner)';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_role_log.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_log IS 'ums_role_log;Stores body metrics of user roles.';

CREATE INDEX gk_role_log_role_id ON sous_chef_ums.ums_role_log (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_log_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';


DROP TABLE IF EXISTS sous_chef_ums.ums_role_preference;
CREATE TABLE sous_chef_ums.ums_role_preference(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    preference_id INT8 NOT NULL,
    level INT2 DEFAULT 1,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.id IS 'Role preference id;Role preference ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.role_id IS 'Role id;Role id (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.preference_id IS 'Preference id;Preference id (FK, preference_id -> preference.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.level IS 'Preference level;Preference level: [1-like, 2-favorite]';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_role_preference.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_preference IS 'ums_role_preference;The dietary preference of specific dining role';

CREATE INDEX gk_role_preference_role_id ON sous_chef_ums.ums_role_preference (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_preference_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';
CREATE INDEX gk_role_preference_preference_id ON sous_chef_ums.ums_role_preference (
    preference_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_preference_preference_id IS 'General index of preference id;The general index of preference_id FK to id in preference table';


DROP TABLE IF EXISTS sous_chef_ums.ums_role_restriction;
CREATE TABLE sous_chef_ums.ums_role_restriction(
    id BIGSERIAL NOT NULL,
    role_id INT8 NOT NULL,
    restriction_id INT8 NOT NULL,
    type INT2 DEFAULT 1,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.id IS 'Role restriction id;Role restriction ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.role_id IS 'Role id;Role id (FK, role_id -> user_role.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.restriction_id IS 'Restriction id;Restriction id (FK, restriction_id -> restriction.id)';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.type IS 'Restriction type;Restriction type: [1-allergic, 2-taboo]';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_role_restriction.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_role_restriction IS 'ums_role_restriction;The dietary restrictions of specific dining role';

CREATE INDEX gk_role_restriction_role_id ON sous_chef_ums.ums_role_restriction (
    role_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_restriction_role_id IS 'General index of role id;The general index of role_id FK to id in user_role table';
CREATE INDEX gk_role_restriction_restriction_id ON sous_chef_ums.ums_role_restriction (
    restriction_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_role_restriction_restriction_id IS 'General index of restriction id;The general index of restriction_id FK to id in restriction table';


DROP TABLE IF EXISTS sous_chef_ums.ums_user_role;
CREATE TABLE sous_chef_ums.ums_user_role(
    id BIGSERIAL NOT NULL,
    user_id INT8 NOT NULL,
    name VARCHAR(50) NOT NULL,
    account_owner BOOLEAN DEFAULT FALSE,
    gender INT2 DEFAULT 0,
    birthdate DATE,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_user_role.id IS 'Role id;Role ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.user_id IS 'User id;User ID (FK, user_id -> user.id)';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.name IS 'Role name;Role name (e.g., grandpa, daughter, friend A)';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.account_owner IS 'Account owner;Whether this role is the account owner';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.gender IS 'Gender;Role gender: [0 - Unknown, 1 - Male, 2 - Female]';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.birthdate IS 'Birthdate;The birthdate of user role';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_user_role.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_user_role IS 'ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.';

CREATE INDEX gk_user_role_user_id ON sous_chef_ums.ums_user_role (
    user_id ASC
);
COMMENT ON INDEX sous_chef_ums.gk_user_role_user_id IS 'General index of user id;The general index of user_id FK to id in user table';


DROP TABLE IF EXISTS sous_chef_ums.ums_user;
CREATE TABLE sous_chef_ums.ums_user(
    id BIGSERIAL NOT NULL,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(50),
    avatar_url VARCHAR(255),
    last_login_at TIMESTAMP,
    status INT2 DEFAULT 1,
    create_dept INT8,
    create_by INT8,
    create_time TIMESTAMP,
    update_by INT8,
    update_time TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON COLUMN sous_chef_ums.ums_user.id IS 'User id;User ID (PK)';
COMMENT ON COLUMN sous_chef_ums.ums_user.username IS 'User name;Username (for login function)';
COMMENT ON COLUMN sous_chef_ums.ums_user.email IS 'User email;Registration email (for login, receiving notifications, and retrieving password)';
COMMENT ON COLUMN sous_chef_ums.ums_user.password_hash IS 'Encrypted password;The hash value of user password, avoid saving plain text';
COMMENT ON COLUMN sous_chef_ums.ums_user.display_name IS 'Name for display;Display name (e.g., Cooker Allen)';
COMMENT ON COLUMN sous_chef_ums.ums_user.avatar_url IS 'URL of avatar;Avatar (optional)';
COMMENT ON COLUMN sous_chef_ums.ums_user.last_login_at IS 'User last login time;Last login time';
COMMENT ON COLUMN sous_chef_ums.ums_user.status IS 'The status of user account;Account status: [0 - Disable, 1 - Enable]';
COMMENT ON COLUMN sous_chef_ums.ums_user.create_dept IS 'Creation department id';
COMMENT ON COLUMN sous_chef_ums.ums_user.create_by IS 'Creator id';
COMMENT ON COLUMN sous_chef_ums.ums_user.create_time IS 'Creation time';
COMMENT ON COLUMN sous_chef_ums.ums_user.update_by IS 'Updater id';
COMMENT ON COLUMN sous_chef_ums.ums_user.update_time IS 'Update time';
COMMENT ON TABLE sous_chef_ums.ums_user IS 'ums_user;This table is the master user table, storing the basic information of all users.';

CREATE UNIQUE INDEX uk_user_username ON sous_chef_ums.ums_user (
    username ASC
);
COMMENT ON INDEX sous_chef_ums.uk_user_username IS 'Unique index of username;The unique index of username field in user table';
CREATE UNIQUE INDEX uk_user_email ON sous_chef_ums.ums_user (
    email ASC
);
COMMENT ON INDEX sous_chef_ums.uk_user_email IS 'Unique index of email;The unique index of email field in user table';