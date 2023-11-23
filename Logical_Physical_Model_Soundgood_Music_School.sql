CREATE TABLE instrument_type (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 type_of_instrument VARCHAR(500) NOT NULL,
 brand VARCHAR(500) NOT NULL,
 cost DECIMAL(10,2) NOT NULL
);

ALTER TABLE instrument_type ADD CONSTRAINT PK_instrument_type PRIMARY KEY (id);


CREATE TABLE person (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_number VARCHAR(12) NOT NULL UNIQUE,
 person_name VARCHAR(500) NOT NULL,
 address VARCHAR(500) NOT NULL
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (id);


CREATE TABLE pricing (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 skill_level VARCHAR(500) NOT NULL,
 lesson_type VARCHAR(500) NOT NULL,
 student_fee DECIMAL(10,2) NOT NULL,
 instructor_pay DECIMAL(10,2) NOT NULL,
 sibling_discount DECIMAL(4,3) NOT NULL,
 valid_from TIMESTAMP(6)
);

ALTER TABLE pricing ADD CONSTRAINT PK_pricing PRIMARY KEY (id);


CREATE TABLE taught_instrument (
 instrument VARCHAR(500) NOT NULL
);

ALTER TABLE taught_instrument ADD CONSTRAINT PK_taught_instrument PRIMARY KEY (instrument);


CREATE TABLE valid_skill_level (
 skill_level VARCHAR(500) NOT NULL
);

ALTER TABLE valid_skill_level ADD CONSTRAINT PK_valid_skill_level PRIMARY KEY (skill_level);


CREATE TABLE contact_details (
 person_id INT NOT NULL,
 phone_number VARCHAR(500) NOT NULL,
 email VARCHAR(500)
);

ALTER TABLE contact_details ADD CONSTRAINT PK_contact_details PRIMARY KEY (person_id);


CREATE TABLE instructor (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE instructor ADD CONSTRAINT PK_instructor PRIMARY KEY (id);


CREATE TABLE instrument (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instrument_type_id INT NOT NULL
);

ALTER TABLE instrument ADD CONSTRAINT PK_instrument PRIMARY KEY (id);


CREATE TABLE known_instrument (
 instructor_id INT NOT NULL,
 instrument VARCHAR(500) NOT NULL
);

ALTER TABLE known_instrument ADD CONSTRAINT PK_known_instrument PRIMARY KEY (instructor_id,instrument);


CREATE TABLE lesson (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 date TIMESTAMP(10) NOT NULL,
 duration INT NOT NULL,
 skill_level VARCHAR(500) NOT NULL,
 pricing_id INT NOT NULL,
 instructor_id INT
);

ALTER TABLE lesson ADD CONSTRAINT PK_lesson PRIMARY KEY (id);


CREATE TABLE student (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 skill_level VARCHAR(500) NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE student ADD CONSTRAINT PK_student PRIMARY KEY (id);


CREATE TABLE student_lesson (
 lesson_id INT NOT NULL,
 student_id INT NOT NULL
);

ALTER TABLE student_lesson ADD CONSTRAINT PK_student_lesson PRIMARY KEY (lesson_id,student_id);


CREATE TABLE contact_person (
 student_id INT NOT NULL,
 contact_name VARCHAR(500) NOT NULL,
 phone_number VARCHAR(500) NOT NULL,
 email VARCHAR(500)
);

ALTER TABLE contact_person ADD CONSTRAINT PK_contact_person PRIMARY KEY (student_id);


CREATE TABLE ensamble (
 lesson_id INT NOT NULL,
 genre VARCHAR(500) NOT NULL,
 min_students INT NOT NULL,
 max_students INT NOT NULL
);

ALTER TABLE ensamble ADD CONSTRAINT PK_ensamble PRIMARY KEY (lesson_id);


CREATE TABLE group_lesson (
 lesson_id INT NOT NULL,
 min_students INT NOT NULL,
 max_students INT NOT NULL,
 instrument VARCHAR(500) NOT NULL
);

ALTER TABLE group_lesson ADD CONSTRAINT PK_group_lesson PRIMARY KEY (lesson_id);


CREATE TABLE individual_lesson (
 lesson_id INT NOT NULL,
 instrument VARCHAR(500) NOT NULL
);

ALTER TABLE individual_lesson ADD CONSTRAINT PK_individual_lesson PRIMARY KEY (lesson_id);


CREATE TABLE rental_service (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instrument_id INT NOT NULL,
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 student_id INT
);

ALTER TABLE rental_service ADD CONSTRAINT PK_rental_service PRIMARY KEY (id);


CREATE TABLE sibling (
 student_id INT NOT NULL,
 sibling_id INT NOT NULL
);

ALTER TABLE sibling ADD CONSTRAINT PK_sibling PRIMARY KEY (student_id,sibling_id);


ALTER TABLE contact_details ADD CONSTRAINT FK_contact_details_0 FOREIGN KEY (person_id) REFERENCES person (id) ON DELETE CASCADE;


ALTER TABLE instructor ADD CONSTRAINT FK_instructor_0 FOREIGN KEY (person_id) REFERENCES person (id);


ALTER TABLE instrument ADD CONSTRAINT FK_instrument_0 FOREIGN KEY (instrument_type_id) REFERENCES instrument_type (id);


ALTER TABLE known_instrument ADD CONSTRAINT FK_known_instrument_0 FOREIGN KEY (instructor_id) REFERENCES instructor (id) ON DELETE CASCADE;
ALTER TABLE known_instrument ADD CONSTRAINT FK_known_instrument_1 FOREIGN KEY (instrument) REFERENCES taught_instrument (instrument);


ALTER TABLE lesson ADD CONSTRAINT FK_lesson_0 FOREIGN KEY (skill_level) REFERENCES valid_skill_level (skill_level);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_1 FOREIGN KEY (pricing_id) REFERENCES pricing (id);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_2 FOREIGN KEY (instructor_id) REFERENCES instructor (id) ON DELETE SET NULL;


ALTER TABLE student ADD CONSTRAINT FK_student_0 FOREIGN KEY (skill_level) REFERENCES valid_skill_level (skill_level);
ALTER TABLE student ADD CONSTRAINT FK_student_1 FOREIGN KEY (person_id) REFERENCES person (id);


ALTER TABLE student_lesson ADD CONSTRAINT FK_student_lesson_0 FOREIGN KEY (lesson_id) REFERENCES lesson (id) ON DELETE CASCADE;
ALTER TABLE student_lesson ADD CONSTRAINT FK_student_lesson_1 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE;


ALTER TABLE contact_person ADD CONSTRAINT FK_contact_person_0 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE;


ALTER TABLE ensamble ADD CONSTRAINT FK_ensamble_0 FOREIGN KEY (lesson_id) REFERENCES lesson (id);


ALTER TABLE group_lesson ADD CONSTRAINT FK_group_lesson_0 FOREIGN KEY (lesson_id) REFERENCES lesson (id) ON DELETE CASCADE;
ALTER TABLE group_lesson ADD CONSTRAINT FK_group_lesson_1 FOREIGN KEY (instrument) REFERENCES taught_instrument (instrument);


ALTER TABLE individual_lesson ADD CONSTRAINT FK_individual_lesson_0 FOREIGN KEY (lesson_id) REFERENCES lesson (id) ON DELETE CASCADE;
ALTER TABLE individual_lesson ADD CONSTRAINT FK_individual_lesson_1 FOREIGN KEY (instrument) REFERENCES taught_instrument (instrument);


ALTER TABLE rental_service ADD CONSTRAINT FK_rental_service_0 FOREIGN KEY (instrument_id) REFERENCES instrument (id);
ALTER TABLE rental_service ADD CONSTRAINT FK_rental_service_1 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE SET NULL;


ALTER TABLE sibling ADD CONSTRAINT FK_sibling_0 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE;
ALTER TABLE sibling ADD CONSTRAINT FK_sibling_1 FOREIGN KEY (sibling_id) REFERENCES student (id) ON DELETE CASCADE;


