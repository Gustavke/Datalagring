CREATE TABLE historical_lesson (
 lesson_id INT NOT NULL,
 lesson_type VARCHAR(500) NOT NULL,
 genre VARCHAR(500),
 instrument VARCHAR(500),
 lesson_price DECIMAL(10,2) NOT NULL
);

ALTER TABLE historical_lesson ADD CONSTRAINT PK_historical_lesson PRIMARY KEY (lesson_id);


CREATE TABLE historical_student (
 student_id INT NOT NULL,
 student_name VARCHAR(500) NOT NULL,
 student_email VARCHAR(500) NOT NULL
);

ALTER TABLE historical_student ADD CONSTRAINT PK_historical_student PRIMARY KEY (student_id);


CREATE TABLE historical_student_lesson (
 student_id INT NOT NULL,
 lesson_id INT NOT NULL
);

ALTER TABLE historical_student_lesson ADD CONSTRAINT PK_historical_student_lesson PRIMARY KEY (student_id,lesson_id);


ALTER TABLE historical_student_lesson ADD CONSTRAINT FK_historical_student_lesson_0 FOREIGN KEY (student_id) REFERENCES historical_student (student_id);
ALTER TABLE historical_student_lesson ADD CONSTRAINT FK_historical_student_lesson_1 FOREIGN KEY (lesson_id) REFERENCES historical_lesson (lesson_id);


