--Number of lessons given by each instructor during current month.
CREATE OR REPLACE VIEW lessons_per_instructor_current_month AS 
SELECT i.id AS "Instructor id", 
		p.person_name AS "Name", 
		count(l.instructor_id) AS "Number of lessons"
FROM instructor i
JOIN person p ON p.id = i.person_id
LEFT JOIN ( 
	--Select all instructor ids from lesson table that is present in current month
	SELECT lesson.instructor_id
	FROM lesson
	WHERE date_trunc('month', lesson.date) = date_trunc('month', CURRENT_DATE)
	) l ON l.instructor_id = i.id
GROUP BY i.id, p.person_name
ORDER BY "Number of lessons" DESC;

--------------------------------------------------------------------

--Number of lessons given per month and category
CREATE OR REPLACE VIEW lessons_per_month AS 
SELECT to_char(date_trunc('month', l.date), 'Month') AS "Month",
		count(l.id) AS "Total",
		count(il.lesson_id) AS "Individual",
		count(gl.lesson_id) AS "Group",
		count(e.lesson_id) AS "Ensemble"
FROM lesson l
LEFT JOIN individual_lesson il ON il.lesson_id = l.id
LEFT JOIN group_lesson gl ON gl.lesson_id = l.id
LEFT JOIN ensemble e ON e.lesson_id = l.id
GROUP BY (date_trunc('month', l.date))
ORDER BY (date_trunc('month', l.date));

--------------------------------------------------------------------
  
--Students with a number of siblings
CREATE OR REPLACE VIEW number_of_siblings AS 
SELECT sibling_count AS "Number of siblings",
		count(sibling_count) AS "Number of students"
FROM ( 
	SELECT count(si.student_id) AS sibling_count
	FROM student st
	LEFT JOIN sibling si ON si.student_id = st.id
	GROUP BY st.id
	) count_of_siblings_per_student
GROUP BY sibling_count
ORDER BY sibling_count;