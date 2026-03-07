CREATE TABLE IF NOT EXISTS skills (
  id BIGINT PRIMARY KEY,
  code VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(128) NOT NULL,
  max_level INT NOT NULL
);

CREATE TABLE IF NOT EXISTS equipments (
  id BIGINT PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  part VARCHAR(32) NOT NULL,
  rarity INT NOT NULL,
  weapon_type VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS equipment_skill_points (
  equipment_id BIGINT NOT NULL,
  skill_code VARCHAR(64) NOT NULL,
  points INT NOT NULL,
  PRIMARY KEY (equipment_id, skill_code),
  CONSTRAINT fk_esp_equipment FOREIGN KEY (equipment_id) REFERENCES equipments (id)
);
