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


CREATE OR REPLACE FUNCTION create_rental(
    vstudent_id INTEGER,
    vtype_of_instrument VARCHAR,
    Vbrand VARCHAR,
    Vstart_date DATE,
    Vend_date DATE
)
RETURNS VOID AS $$
DECLARE
    available_instrument INTEGER;
BEGIN
    SELECT i.id
    INTO available_instrument
    FROM instrument_type AS t
    JOIN instrument i ON i.instrument_type_id = t.id
    WHERE NOT EXISTS (
        SELECT 1
        FROM rental_service r
        WHERE r.instrument_id = i.id AND r.end_date >= Vstart_date
    )
    AND t.type_of_instrument = Vtype_of_instrument AND t.brand = Vbrand
    LIMIT 1;

    IF available_instrument IS NULL THEN
        RAISE EXCEPTION 'No available instrument for the specified type and brand';
    ELSE
        INSERT INTO rental_service (student_id, instrument_id, start_date, end_date) 
        VALUES (Vstudent_id, available_instrument, Vstart_date, Vend_date);
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION check_active_rentals()
RETURNS TRIGGER AS $$
DECLARE
    active_count INTEGER;
BEGIN
SELECT COUNT(*)
INTO active_count
FROM rental_service
WHERE student_id = NEW.student_id AND end_date >= NEW.start_date;
	
IF active_count >= 2 THEN
	RAISE EXCEPTION 'Student already has two active rentals';
END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER before_insert_rental
BEFORE INSERT ON rental_service
FOR EACH ROW
EXECUTE FUNCTION check_active_rentals();




CREATE OR REPLACE FUNCTION insert_lesson(
    p_date TIMESTAMP,
    p_lesson_type VARCHAR(500),
    p_skill_level VARCHAR(500),
    p_instrument_or_genre VARCHAR(500)
)
RETURNS VOID AS $$
DECLARE
    v_instructor_id INT;
    v_pricing_id INT;
    v_lesson_id INT;
BEGIN
    -- Find an instructor who knows the instrument or a random instructor if no match
    SELECT COALESCE(
            (SELECT i.id
             FROM known_instrument ki
             JOIN instructor i ON ki.instructor_id = i.id
             WHERE ki.instrument = p_instrument_or_genre
             LIMIT 1),
            (SELECT id FROM instructor ORDER BY random() LIMIT 1)
        )
    INTO v_instructor_id;

    -- Find pricing scheme matching skill level and lesson type with the latest valid from date
    SELECT id
    INTO v_pricing_id
    FROM pricing
    WHERE skill_level = p_skill_level
      AND lesson_type = p_lesson_type
      AND valid_from <= p_date
    ORDER BY valid_from DESC
    LIMIT 1;

    -- Insert the lesson
    INSERT INTO lesson (date,duration, skill_level, pricing_id, instructor_id)
    VALUES (p_date, 60, p_skill_level, v_pricing_id, v_instructor_id)
    RETURNING id INTO v_lesson_id;

    -- Determine lesson type and create associated record
    CASE p_lesson_type
        WHEN 'Individual' THEN
            INSERT INTO individual_lesson (lesson_id, instrument)
            VALUES (v_lesson_id, p_instrument_or_genre);
        WHEN 'Group' THEN
            INSERT INTO group_lesson (lesson_id, min_students, max_students, instrument)
            VALUES (v_lesson_id, 5, 12, p_instrument_or_genre);
        WHEN 'Ensemble' THEN
            INSERT INTO ensamble (lesson_id, min_students, max_students, genre)
            VALUES (v_lesson_id, 5, 12, p_instrument_or_genre);
        ELSE
            -- Handle other cases or raise an exception as needed
            RAISE EXCEPTION 'Invalid lesson type: %', p_lesson_type;
    END CASE;
END;
$$ LANGUAGE plpgsql;



INSERT INTO pricing (skill_level, lesson_type, student_fee, instructor_pay, sibling_discount, valid_from)
VALUES 
    ('Beginner', 'Individual', 50.00, 30.00, 0.10, CURRENT_DATE),
    ('Beginner', 'Group', 30.00, 20.00, 0.10, CURRENT_DATE),
    ('Beginner', 'Ensemble', 40.00, 25.00, 0.10, CURRENT_DATE),

    ('Intermediate', 'Individual', 60.00, 40.00, 0.15, CURRENT_DATE),
    ('Intermediate', 'Group', 40.00, 25.00, 0.15, CURRENT_DATE),
    ('Intermediate', 'Ensemble', 50.00, 30.00, 0.15, CURRENT_DATE),

    ('Advanced', 'Individual', 70.00, 50.00, 0.20, CURRENT_DATE),
    ('Advanced', 'Group', 50.00, 35.00, 0.20, CURRENT_DATE),
    ('Advanced', 'Ensemble', 60.00, 40.00, 0.20, CURRENT_DATE);


    -- Insert Individual Lessons
DO $$ 
DECLARE
    lesson_date TIMESTAMP;
    instrument_type VARCHAR(500);
BEGIN
    FOR month_offset IN 0..11 LOOP
        lesson_date := CURRENT_DATE + (interval '1 month' * month_offset);
        FOR lesson_count IN 1..2 LOOP
            FOR instrument_type IN SELECT unnest(ARRAY['Piano', 'Violin', 'Guitar', 'Flute', 'Trumpet', 'Drums', 'Saxophone', 'Clarinet', 'Cello', 'Trombone'])
            LOOP
                PERFORM insert_lesson(
                    lesson_date + interval '1 day' * (lesson_count - 1),
                    'Individual',
                    CASE lesson_count
                        WHEN 1 THEN 'Beginner'
                        WHEN 2 THEN 'Intermediate'
                    END,
                    instrument_type
                );
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- Insert Group Lessons
DO $$ 
DECLARE
    lesson_date TIMESTAMP;
    instrument_type VARCHAR(500);
BEGIN
    FOR month_offset IN 0..11 LOOP
        lesson_date := CURRENT_DATE + (interval '1 month' * month_offset);
        FOR lesson_count IN 1..2 LOOP
            FOR instrument_type IN SELECT unnest(ARRAY['Piano', 'Violin', 'Guitar', 'Flute', 'Trumpet', 'Drums', 'Saxophone', 'Clarinet', 'Cello', 'Trombone'])
            LOOP
                PERFORM insert_lesson(
                    lesson_date + interval '1 day' * (lesson_count - 1),
                    'Group',
                    CASE lesson_count
                        WHEN 1 THEN 'Intermediate'
                        WHEN 2 THEN 'Advanced'
                    END,
                    instrument_type
                );
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- Insert Ensemble Lessons
DO $$ 
DECLARE
    lesson_date TIMESTAMP;
    genre VARCHAR(500);
BEGIN
    FOR month_offset IN 0..11 LOOP
        lesson_date := CURRENT_DATE + (interval '1 month' * month_offset);
        FOR lesson_count IN 1..2 LOOP
            FOR genre IN SELECT unnest(ARRAY['Jazz', 'Classical', 'Rock', 'Pop'])
            LOOP
                PERFORM insert_lesson(
                    lesson_date + interval '1 day' * (lesson_count - 1),
                    'Ensemble',
                    CASE lesson_count
                        WHEN 1 THEN 'Beginner'
                        WHEN 2 THEN 'Advanced'
                    END,
                    genre
                );
            END LOOP;
        END LOOP;
    END LOOP;
END $$;



INSERT INTO sibling (student_id, sibling_id) VALUES (1, 2), (1, 3);
INSERT INTO sibling (student_id, sibling_id) VALUES (2, 1), (2, 3);
INSERT INTO sibling (student_id, sibling_id) VALUES (3, 1), (3, 2);


INSERT INTO sibling (student_id, sibling_id) VALUES (4, 5);
INSERT INTO sibling (student_id, sibling_id) VALUES (5, 4);


INSERT INTO sibling (student_id, sibling_id) VALUES (6, 7), (6, 8), (6, 9);
INSERT INTO sibling (student_id, sibling_id) VALUES (7, 6), (7, 8), (7, 9);
INSERT INTO sibling (student_id, sibling_id) VALUES (8, 6), (8, 7), (8, 9);
INSERT INTO sibling (student_id, sibling_id) VALUES (9, 6), (9, 7), (9, 8);


INSERT INTO sibling (student_id, sibling_id) VALUES (10, 11);
INSERT INTO sibling (student_id, sibling_id) VALUES (11, 10);


INSERT INTO sibling (student_id, sibling_id) VALUES (12, 13), (12, 14);
INSERT INTO sibling (student_id, sibling_id) VALUES (13, 12), (13, 14);
INSERT INTO sibling (student_id, sibling_id) VALUES (14, 12), (14, 13);


INSERT INTO sibling (student_id, sibling_id) VALUES (15, 16);
INSERT INTO sibling (student_id, sibling_id) VALUES (16, 15);


INSERT INTO sibling (student_id, sibling_id) VALUES (150, 151), (150, 152);
INSERT INTO sibling (student_id, sibling_id) VALUES (151, 150), (151, 152);
INSERT INTO sibling (student_id, sibling_id) VALUES (152, 150), (152, 151);


INSERT INTO sibling (student_id, sibling_id) VALUES (153, 154);
INSERT INTO sibling (student_id, sibling_id) VALUES (154, 153);


INSERT INTO sibling (student_id, sibling_id) VALUES (155, 156), (155, 157), (155, 158);
INSERT INTO sibling (student_id, sibling_id) VALUES (156, 155), (156, 157), (156, 158);
INSERT INTO sibling (student_id, sibling_id) VALUES (157, 155), (157, 156), (157, 158);
INSERT INTO sibling (student_id, sibling_id) VALUES (158, 155), (158, 156), (158, 157);


INSERT INTO sibling (student_id, sibling_id) VALUES (159, 160);
INSERT INTO sibling (student_id, sibling_id) VALUES (160, 159);


INSERT INTO sibling (student_id, sibling_id) VALUES (161, 162), (161, 163);
INSERT INTO sibling (student_id, sibling_id) VALUES (162, 161), (162, 163);
INSERT INTO sibling (student_id, sibling_id) VALUES (163, 161), (163, 162);


INSERT INTO sibling (student_id, sibling_id) VALUES (164, 165);
INSERT INTO sibling (student_id, sibling_id) VALUES (165, 164);


