INSERT INTO historical_lesson
SELECT l.id AS "lesson_id",
	CASE
	WHEN il.lesson_id IS NOT NULL THEN 'Individual'
	WHEN gl.lesson_id IS NOT NULL THEN 'Group'
	WHEN e.lesson_id IS NOT NULL THEN 'Ensemble'
	END AS lesson_type, 
	e.genre AS "genre", 
	CASE
	WHEN il.instrument IS NOT NULL THEN il.instrument
	WHEN gl.instrument IS NOT NULL THEN gl.instrument
	END AS "instrument", 
	p.student_fee AS "lesson_price"
FROM lesson l
LEFT JOIN individual_lesson il ON il.lesson_id = l.id
LEFT JOIN group_lesson gl ON gl.lesson_id = l.id
LEFT JOIN ensemble e ON e.lesson_id = l.id
JOIN pricing p ON p.id = l.pricing_id
WHERE l.id NOT IN (SELECT lesson_id FROM historical_lesson)


MERGE INTO historical_student tgt
USING (
	SELECT s.id, p.person_name, c.email
	FROM person p
	JOIN student s ON s.person_id = p.id
	JOIN contact_details c ON c.person_id = p.id
	WHERE s.id IN (SELECT student_id FROM student_lesson)
		OR s.id IN (SELECT student_id FROM historical_student_lesson)
	) src
ON tgt.student_id = src.id
WHEN MATCHED AND (student_name != person_name OR student_email != email) THEN
	UPDATE SET student_name = src.person_name, student_email = src.email
WHEN NOT MATCHED THEN 
	INSERT (student_id, student_name, student_email)
	VALUES(src.id, src.person_name, src.email);

    
INSERT INTO historical_student_lesson
SELECT student_id, lesson_id FROM student_lesson sl
WHERE NOT EXISTS (
					SELECT 1 
					FROM historical_student_lesson hsl
					WHERE sl.student_id = hsl.student_id
					AND sl.lesson_id = hsl.lesson_id
				 )