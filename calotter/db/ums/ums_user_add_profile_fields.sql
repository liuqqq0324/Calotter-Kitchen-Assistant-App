-- Migration script to add profile fields to ums_user table
-- Run this script on existing databases to add age, height, weight, gender columns

ALTER TABLE sous_chef_ums.ums_user
ADD COLUMN IF NOT EXISTS age INTEGER,
ADD COLUMN IF NOT EXISTS height INTEGER,
ADD COLUMN IF NOT EXISTS weight INTEGER,
ADD COLUMN IF NOT EXISTS gender VARCHAR(20);

COMMENT ON COLUMN sous_chef_ums.ums_user.age IS 'User age;User age in years';
COMMENT ON COLUMN sous_chef_ums.ums_user.height IS 'User height;User height in cm';
COMMENT ON COLUMN sous_chef_ums.ums_user.weight IS 'User weight;User weight in kg';
COMMENT ON COLUMN sous_chef_ums.ums_user.gender IS 'User gender;User gender (e.g., male, female, other)';
