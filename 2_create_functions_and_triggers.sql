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
            INSERT INTO ensemble (lesson_id, min_students, max_students, genre)
            VALUES (v_lesson_id, 5, 12, p_instrument_or_genre);
        ELSE
            -- Handle other cases or raise an exception as needed
            RAISE EXCEPTION 'Invalid lesson type: %', p_lesson_type;
    END CASE;
END;
$$ LANGUAGE plpgsql;