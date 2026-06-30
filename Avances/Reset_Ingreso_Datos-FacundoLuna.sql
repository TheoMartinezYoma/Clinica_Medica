USE Clinica_Medica;
GO

-- =============================================
-- LIMPIEZA DE TABLAS (orden respetando FK)
-- =============================================

DELETE FROM HistorialMedico;
DELETE FROM TurnosMedico;
DELETE FROM Turnos;
DELETE FROM MedicoHorario;
DELETE FROM HorarioAtencion;
DELETE FROM MedicoEspecialidad;
DELETE FROM Medico;
DELETE FROM Paciente;
DELETE FROM Persona;
DELETE FROM ObraSocial;
DELETE FROM Especialidad;
DELETE FROM Consultorio;
DELETE FROM TipoTurno;
GO

-- =============================================
-- RESETEO DE IDENTITY
-- =============================================

DBCC CHECKIDENT ('HistorialMedico',  RESEED, 0);
DBCC CHECKIDENT ('TurnosMedico',     RESEED, 0);
DBCC CHECKIDENT ('Turnos',           RESEED, 0);
DBCC CHECKIDENT ('MedicoHorario',    RESEED, 0);
DBCC CHECKIDENT ('HorarioAtencion',  RESEED, 0);
DBCC CHECKIDENT ('MedicoEspecialidad', RESEED, 0);
DBCC CHECKIDENT ('Medico',           RESEED, 0);
DBCC CHECKIDENT ('Persona',          RESEED, 0);
DBCC CHECKIDENT ('ObraSocial',       RESEED, 0);
DBCC CHECKIDENT ('Especialidad',     RESEED, 0);
DBCC CHECKIDENT ('Consultorio',      RESEED, 0);
DBCC CHECKIDENT ('TipoTurno',        RESEED, 0);
GO

-- =============================================
-- CARGA DE DATOS DE PRUEBA
-- =============================================

-- OBRAS SOCIALES (4 registros)
INSERT INTO ObraSocial (RazonSocial, Activo)
VALUES
    ('OSDE',          1),
    ('Swiss Medical', 1),
    ('Medifé',        1),
    ('IOMA',          0);   -- inactiva para probar filtros
GO

-- ESPECIALIDADES (4 registros)
INSERT INTO Especialidad (Nombre)
VALUES
    ('Cardiología'),
    ('Clínica Médica'),
    ('Pediatría'),
    ('Traumatología');
GO

-- CONSULTORIOS (4 registros)
INSERT INTO Consultorio (NroConsultorio, Piso, Descripcion)
VALUES
    (101, 1, 'Consultorio General'),
    (202, 2, 'Consultorio Cardiología'),
    (305, 3, 'Consultorio Pediatría'),
    (401, 4, 'Consultorio Traumatología');
GO

-- TIPOS DE TURNO (4 estados fijos)
INSERT INTO TipoTurno (Descripcion)
VALUES
    ('Agendado'),
    ('Confirmado'),
    ('Cancelado'),
    ('Realizado');
GO

-- PERSONAS
-- IDs 1-3: pacientes | IDs 4-7: médicos | ID 8: personal extra
INSERT INTO Persona (Nombre, Apellido, DNI, Telefono, Nacionalidad, Mail, FechaNacimiento)
VALUES
    ('Juan',     'Pérez',     '30111222', '1122334455', 'Argentina', 'juan.perez@gmail.com',      '1990-03-10'),
    ('María',    'López',     '28999111', '1166677788', 'Argentina', 'maria.lopez@gmail.com',     '1988-07-21'),
    ('Facundo',  'Luna',      '42836127', '1134546545', 'Argentina', 'facundo.luna@gmail.com',    '2000-07-09'),
    ('Carlos',   'Gómez',     '20123123', '1144455566', 'Argentina', 'cgomez@gmail.com',          '1975-05-02'),
    ('Ana',      'Martínez',  '22333444', '1177788899', 'Argentina', 'amartinez@gmail.com',       '1980-11-15'),
    ('Roberto',  'Fernández', '18500600', '1199001122', 'Argentina', 'rfernandez@gmail.com',      '1970-02-28'),
    ('Lucía',    'Ramírez',   '35678901', '1155443322', 'Argentina', 'lramirez@gmail.com',        '1995-09-14'),
    ('Sofía',    'Blanco',    '40123456', '1188776655', 'Argentina', 'sblanco@gmail.com',         '2002-12-01');
GO

-- PACIENTES (personas 1, 2 y 3)
INSERT INTO Paciente (idPersona, Localidad, idObraSocial, NumeroOS, FechaIngreso, Activo)
VALUES
    (1, 'Buenos Aires',    1, 123456789, '2026-01-10', 1),
    (2, 'Lanús',           2, 987654321, '2026-01-15', 1),
    (3, 'General Pacheco', 3, 111222333, '2026-02-01', 1);
GO

-- MÉDICOS (personas 4, 5, 6 y 7)
INSERT INTO Medico (idPersona, NumMatricula, Activo)
VALUES
    (4, 'MP12345', 1),   -- Carlos Gómez
    (5, 'MP54321', 1),   -- Ana Martínez
    (6, 'MP99988', 1),   -- Roberto Fernández
    (7, 'MP77711', 1);   -- Lucía Ramírez
GO

-- ESPECIALIDADES POR MÉDICO
-- Médico 1 (Carlos): Cardiología
-- Médico 2 (Ana):    Clínica Médica + Pediatría
-- Médico 3 (Roberto): Traumatología
-- Médico 4 (Lucía):  Pediatría + Cardiología
INSERT INTO MedicoEspecialidad (idMedico, idEspecialidad)
VALUES
    (1, 1),   -- Carlos -> Cardiología
    (2, 2),   -- Ana    -> Clínica Médica
    (2, 3),   -- Ana    -> Pediatría
    (3, 4),   -- Roberto -> Traumatología
    (4, 3),   -- Lucía  -> Pediatría
    (4, 1);   -- Lucía  -> Cardiología
GO

-- HORARIOS DE ATENCIÓN
INSERT INTO HorarioAtencion (Fecha, horaInicio, horaFin, Cupos, Activo)
VALUES
    ('2026-07-07', '08:00', '12:00', 8, 1),
    ('2026-07-07', '14:00', '18:00', 6, 1),
    ('2026-07-08', '09:00', '13:00', 8, 1),
    ('2026-07-10', '08:00', '12:00', 10, 1);
GO

-- MÉDICO-HORARIO
INSERT INTO MedicoHorario (idMedico, idHorario)
VALUES
    (1, 1),   -- Carlos mañana lunes
    (2, 1),   -- Ana mañana lunes
    (3, 2),   -- Roberto tarde lunes
    (4, 3),   -- Lucía mañana martes
    (1, 4);   -- Carlos mañana jueves
GO

-- =============================================
-- TURNOS
-- Algunos en el futuro (para probar Agendado/Confirmado)
-- Algunos en el pasado (para probar sp_ActualizarTurnosVencidos)
-- =============================================
INSERT INTO Turnos (idMedico, idEspecialidad, FechaHora, idConsultorio, idTipoTurno, idPaciente)
VALUES
    -- Turno 1: futuro - Agendado
    (1, 1, '2026-07-07 09:00', 2, 1, 1),   -- Carlos | Cardiología | Juan

    -- Turno 2: futuro - Confirmado
    (2, 2, '2026-07-07 09:30', 1, 2, 2),   -- Ana | Clínica Médica | María

    -- Turno 3: futuro - Agendado
    (4, 3, '2026-07-08 10:00', 3, 1, 3),   -- Lucía | Pediatría | Facundo

    -- Turno 4: pasado - Agendado (quedó sin actualizar, para probar sp_ActualizarTurnosVencidos)
    (3, 4, '2026-06-10 11:00', 4, 1, 1),   -- Roberto | Traumatología | Juan

    -- Turno 5: pasado - ya Realizado
    (2, 2, '2026-06-15 14:30', 1, 4, 2),   -- Ana | Clínica Médica | María

    -- Turno 6: Cancelado
    (1, 1, '2026-07-10 08:00', 2, 3, 3),   -- Carlos | Cardiología | Facundo

    -- Turno 7: futuro - Confirmado, mismo médico distinta hora
    (1, 1, '2026-07-10 09:00', 2, 2, 1);   -- Carlos | Cardiología | Juan
GO

-- =============================================
-- HISTORIALES MÉDICOS
-- Solo para turnos pasados/realizados (IDs 4 y 5)
-- =============================================
INSERT INTO HistorialMedico (idTurno, FechaAtencion, MotivoConsulta, Diagnostico, Tratamiento, Observaciones)
VALUES
    (
        4,
        '2026-06-10',
        'Dolor en rodilla derecha',
        'Esguince grado I',
        'Reposo 7 días + antiinflamatorios',
        'Control en 2 semanas'
    ),
    (
        5,
        '2026-06-15',
        'Fiebre y dolor de garganta',
        'Faringitis bacteriana',
        'Amoxicilina 500mg cada 8hs por 7 días',
        'Próximo control si no mejora en 72hs'
    );
GO

-- =============================================
-- VERIFICACIÓN RÁPIDA
-- =============================================
PRINT '=== RESUMEN DE DATOS CARGADOS ===';

SELECT 'ObraSocial'        AS Tabla, COUNT(*) AS Registros FROM ObraSocial     UNION ALL
SELECT 'Especialidad',               COUNT(*)               FROM Especialidad   UNION ALL
SELECT 'Consultorio',                COUNT(*)               FROM Consultorio    UNION ALL
SELECT 'TipoTurno',                  COUNT(*)               FROM TipoTurno      UNION ALL
SELECT 'Persona',                    COUNT(*)               FROM Persona        UNION ALL
SELECT 'Paciente',                   COUNT(*)               FROM Paciente       UNION ALL
SELECT 'Medico',                     COUNT(*)               FROM Medico         UNION ALL
SELECT 'MedicoEspecialidad',         COUNT(*)               FROM MedicoEspecialidad UNION ALL
SELECT 'HorarioAtencion',            COUNT(*)               FROM HorarioAtencion UNION ALL
SELECT 'MedicoHorario',              COUNT(*)               FROM MedicoHorario  UNION ALL
SELECT 'Turnos',                     COUNT(*)               FROM Turnos         UNION ALL
SELECT 'HistorialMedico',            COUNT(*)               FROM HistorialMedico;
GO
