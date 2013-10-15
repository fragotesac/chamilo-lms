INSERT INTO roles (name, role) VALUES('Jury president', 'ROLE_JURY_PRESIDENT');
INSERT INTO roles (name, role) VALUES('Jury member', 'ROLE_JURY_MEMBER');
INSERT INTO roles (name, role) VALUES('Jury substitute', 'ROLE_JURY_SUBSTITUTE');
INSERT INTO roles (name, role) VALUES('Director', 'ROLE_DIRECTOR');

-- Add new configuration setting for action related transaction settings.
INSERT INTO settings_current (variable, subkey, type, category, selected_value, title, comment, scope, subkeytext, access_url_changeable) VALUES ('log_transactions','exercise_attempt','checkbox','LogTransactions','false','LogTransactionsForExerciseAttempts','LogTransactionsForExerciseAttemptsComment',NULL,'LogTransactionsForExerciseAttemptsText', 1);
INSERT INTO settings_current (variable, subkey, type, category, selected_value, title, comment, scope, subkeytext, access_url_changeable) VALUES ('transaction_action_map','exercise_attempt','text','TransactionMapping','a:0:{}','TransactionMapForExerciseAttempts','TransactionMapForExerciseAttemptsComment',NULL,'TransactionMapForExerciseAttemptsText', 1);

CREATE TABLE jury (
  id int NOT NULL AUTO_INCREMENT,
  name varchar(255) DEFAULT NULL,
  branch_id int NULL,
  opening_date datetime DEFAULT NULL,
  closure_date datetime DEFAULT NULL,
  opening_user_id int DEFAULT NULL,
  closure_user_id int DEFAULT NULL,
  exercise_id int NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE jury_members (
    id int NOT NULL AUTO_INCREMENT,
    user_id int,
    role_id int,
    jury_id int,
    PRIMARY KEY(id)
);

CREATE TABLE branch_users (
    id int NOT NULL AUTO_INCREMENT,
    user_id int,
    branch_id int,
    role_id int,
    PRIMARY KEY(id)
);

CREATE TABLE track_attempt_jury(
    id int NOT NULL AUTO_INCREMENT,
    exe_id INT,
    question_id INT,
    score float(6,2),
    jury_user_id INT,
    question_score_name_id INT,
    PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


ALTER TABLE track_e_exercices ADD COLUMN jury_score float(6,2);
ALTER TABLE track_e_exercices ADD COLUMN jury_id INT DEFAULT NULL;

-- Rename the transaction import log table and change its structure.
RENAME TABLE branch_sync_log TO branch_transaction_log;

UPDATE settings_current SET selected_value = 'minedu' WHERE variable = 'template';
UPDATE settings_current SET selected_value = 'digedd' WHERE variable = 'stylesheets';

DROP TABLE c_quiz_distribution;
CREATE TABLE c_quiz_distribution (
  id int unsigned not null primary key AUTO_INCREMENT,
  exercise_id int unsigned not null,
  title varchar(255) not null,
  -- the list of questions id that the student will have to go through for this form, split by ","
  -- (as in track_e_exercices - this will avoid 60 more queries to the next table once the exam is taking place)
  data_tracking text not null default '',
  active tinyint not null default 1,
  author_user_id int unsigned not null,
  last_generation_date datetime default null
);

CREATE TABLE c_quiz_distribution_questions (
  id int unsigned not null primary key AUTO_INCREMENT,
  quiz_distribution_id int unsigned not null, -- the id of the quiz distribution
  category_id int unsigned, -- the (global) category ID of the question that has been selected
  question_id int unsigned -- the (global) question ID
);

CREATE TABLE c_quiz_distribution_rel_session (
  id int unsigned not null primary key AUTO_INCREMENT,
  session_id int unsigned not null, -- the session id
  c_id int unsigned not null, -- the course id (in case more than one course per session)
  exercise_id int unsigned not null, -- the quiz global id
  quiz_distribution_id int unsigned not null -- one of the valid distributions for this turn
);

-- store the distribution ID that was assigned to this user (SUPER IMPORTANT TRACKING INFO, DO NOT MISS THIS)
ALTER TABLE track_e_exercices ADD COLUMN quiz_distribution_id int unsigned default null;

-- Fields re-structuring corresponding to plugin generalization.
ALTER TABLE branch_sync
  DROP ssl_pub_key,
  ADD plugin_envelope varchar(250) null default null,
  ADD plugin_send varchar(250) null default null,
  ADD plugin_receive varchar(250) null default null,
  ADD data TEXT null DEFAULT null COMMENT 'Serialized php array with extra information for the branch. Mainly used by its plugins.';

-- Generalize a little more the transaction log table.
ALTER TABLE branch_transaction_log
  ADD log_type int not null after id,
  CHANGE transaction_id transaction_id bigint unsigned null default null,
  CHANGE import_time log_time datetime not null,
  ADD INDEX (log_type);

-- Adds a table to use as queue for received envelopes.
CREATE TABLE received_envelopes (
  id int not null AUTO_INCREMENT,
  data TEXT not null COMMENT 'The envelope blob.',
  status int not null default 1 COMMENT 'See Envelope::RECEIVED_*',
  PRIMARY KEY(id)
);

-- Include course and session ids on transactions.
ALTER TABLE branch_transaction
  ADD c_id int not null,
  ADD session_id int not null;

-- Adds new setting for the local branch id.
INSERT INTO settings_current (variable, type, category, selected_value, title, comment, access_url_changeable) VALUES
('local_branch_id', 'textfield', 'LogTransactions', 1, 'LogTransactionsDefaultBranch', 'LogTransactionsDefaultBranchComment', 1);
