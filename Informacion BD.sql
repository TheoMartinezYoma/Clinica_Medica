use ClinicaMedica

INSERT INTO Persona (Nombre, Apellido, DNI, Telefono, Nacionalidad, Mail, FechaNacimiento) VALUES 
('Carlos', 'Gómez', '30111222', '1144445555', 'Argentina', 'carlos.gomez@clinica.com', '1980-05-12'),
('Laura', 'Martínez', '32333444', '1155556666', 'Argentina', 'laura.martinez@clinica.com', '1985-08-20'),
('Andrés', 'Fernández', '28555666', '1166667777', 'Argentina', 'andres.fer@clinica.com', '1978-03-04'),
('Juan', 'Pérez', '45111222', '1122223333', 'Argentina', 'juan.perez@mail.com', '2003-01-15'),
('Sofía', 'Rodríguez', '48333444', '1133334444', 'Argentina', 'sofia.rod@mail.com', '2008-11-30'),
('Elena', 'Sanz', '25999888', '1177778888', 'Argentina', 'elena.sanz@clinica.com', '1975-10-02'),
('Lucas', 'Molina', '42111555', '1188889999', 'Argentina', 'lucas.molina@mail.com', '2000-04-25'); 



INSERT INTO ObraSocial (RazonSocial) VALUES 
('OSDE'),
('Swiss Medical'),
('PAMI');

INSERT INTO Especialidad (Nombre) VALUES 
('Pediatría'),
('Cardiología'),
('Clínica Médica'); 


INSERT INTO Paciente (idPersona, Localidad, idObraSocial, NumeroOS, FechaIngreso, Activo) VALUES 
(4, 'San Justo', 1, 987654, '2026-01-10', 1), -- 1 es OSDE
(5, 'Ramos Mejía', 2, 123456, '2026-03-22', 1), -- 2 es Swiss Medical
(7, 'Morón', 3, 444555, '2026-05-05', 1);       -- 3 es PAMI 


INSERT INTO TipoTurno (Descripcion) VALUES
('Confirmado'),
('cancelado'), 
('Pendiente'), 
('Atendido');

INSERT INTO Consultorio (NroConsultorio, Piso, Descripcion)
VALUES
(101,1,'Consultorio General'),
(102,1,'Consultorio Pediatría'),
(201,2,'Consultorio Cardiología'); 

INSERT INTO Medico (idPersona, NumMatricula, HorarioAtencion, Activo)
VALUES
(1,'MP1001',NULL,1),
(2,'MP1002',NULL,1),
(3,'MP1003',NULL,1),
(6,'MP1004',NULL,1); 



INSERT INTO MedicoEspecialidad (idMedico,idEspecialidad)
VALUES
(1,3), -- Carlos -> Clínica Médica
(2,2), -- Laura -> Cardiología
(3,1), -- Andrés -> Pediatría
(4,3); -- Elena -> Clínica Médica 



INSERT INTO HorarioAtencion (Fecha,horaInicio,horaFin,Cupos,Activo)
VALUES
('2026-06-22','08:00','12:00',8,1),
('2026-06-22','13:00','17:00',8,1),
('2026-06-23','08:00','12:00',8,1); 


INSERT INTO MedicoHorario (idMedico,idHorario)
VALUES
(1,1),
(2,2),
(3,3); 



-- Turnos reservados
INSERT INTO Turnos
(idMedico,idEspecialidad,FechaHora,idConsultorio,idTipoTurno,idPaciente)
VALUES
(1,3,'2026-06-22 08:00',1,1,4),
(2,2,'2026-06-22 13:00',3,2,5),
(3,1,'2026-06-23 08:00',3,1,7); 






INSERT INTO TurnosMedico (idHoraAtencion,fechaHora)
VALUES
(1,'2026-06-22 08:00'),
(1,'2026-06-22 08:30'),
(1,'2026-06-22 09:00'),
(1,'2026-06-22 09:30'),
(1,'2026-06-22 10:00'),
(1,'2026-06-22 10:30'),
(1,'2026-06-22 11:00'),
(1,'2026-06-22 11:30');

INSERT INTO TurnosMedico (idHoraAtencion,fechaHora)
VALUES
-- Horario 2
(2,'2026-06-22 13:00'),
(2,'2026-06-22 13:30'),
(2,'2026-06-22 14:00'),
(2,'2026-06-22 14:30'),
(2,'2026-06-22 15:00'),
(2,'2026-06-22 15:30'),
(2,'2026-06-22 16:00'),
(2,'2026-06-22 16:30'), 
(3,'2026-06-23 08:00'),
(3,'2026-06-23 08:30'),
(3,'2026-06-23 09:00'),
(3,'2026-06-23 09:30'),
(3,'2026-06-23 10:00'),
(3,'2026-06-23 10:30'),
(3,'2026-06-23 11:00'),
(3,'2026-06-23 11:30');



INSERT INTO HistorialMedico
(idTurno,FechaAtencion,MotivoConsulta,Diagnostico,Tratamiento,Observaciones)
VALUES
(1,'2026-06-22','Dolor de cabeza','Migraña','Ibuprofeno','Control en una semana'),
 (3, '2026-06-23', 'Control General', 'Sano', 'Ninguno', 'Revisión anual ok');

