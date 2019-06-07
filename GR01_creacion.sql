CREATE TABLE GR01_ALQUILER (
    id_alquiler int  NOT NULL,
    id_cliente int  NOT NULL,
    fecha_desde date  NOT NULL,
    fecha_hasta date  NULL,
    importe_dia decimal(10,2)  NOT NULL,
    CONSTRAINT PK_1_ALQUILER PRIMARY KEY (id_alquiler)
);


CREATE TABLE GR01_ALQUILER_POSICIONES (
    id_alquiler int  NOT NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    estado boolean  NOT NULL,
    CONSTRAINT PK_1_ALQUILER_POSICIONES PRIMARY KEY (id_alquiler,nro_posicion,nro_estanteria,nro_fila)
);


CREATE TABLE GR01_CLIENTE (
    cuit_cuil int  NOT NULL,
    apellido varchar(60)  NOT NULL,
    nombre varchar(40)  NOT NULL,
    fecha_alta date  NOT NULL,
    CONSTRAINT PK_1_CLIENTE PRIMARY KEY (cuit_cuil)
);


CREATE TABLE GR01_ESTANTERIA (
    nro_estanteria int  NOT NULL,
    nombre_estanteria varchar(80)  NOT NULL,
    CONSTRAINT PK_1_ESTANTERIA PRIMARY KEY (nro_estanteria)
);


CREATE TABLE GR01_FILA (
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    nombre_fila varchar(80)  NOT NULL,
    peso_max_kg decimal(10,2)  NOT NULL,
    CONSTRAINT PK_1_FILA PRIMARY KEY (nro_estanteria,nro_fila)
);

CREATE TABLE GR01_MOVIMIENTO (
    id_movimiento int  NOT NULL,
    fecha timestamp  NOT NULL,
    responsable varchar(80)  NOT NULL,
    tipo char(1)  NOT NULL,
    CONSTRAINT PK_1_MOVIMIENTO PRIMARY KEY (id_movimiento)
);

CREATE TABLE GR01_MOV_ENTRADA (
    id_movimiento int  NOT NULL,
    transporte varchar(80)  NOT NULL,
    guia varchar(80)  NOT NULL,
    cod_pallet varchar(20)  NOT NULL,
    id_alquiler int  NOT NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    CONSTRAINT PK_1_MOV_ENTRADA PRIMARY KEY (id_movimiento)
);

CREATE TABLE GR01_MOV_INTERNO (
    id_movimiento int  NOT NULL,
    razon varchar(200)  NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    id_movimiento_interno int  NULL,
    CONSTRAINT PK_1_MOV_INTERNO PRIMARY KEY (id_movimiento)
);

CREATE TABLE GR01_MOV_SALIDA (
    id_movimiento int  NOT NULL,
    transporte varchar(80)  NOT NULL,
    guia varchar(80)  NOT NULL,
    id_movimiento_entrada int  NOT NULL,
    CONSTRAINT PK_1_MOV_SALIDA PRIMARY KEY (id_movimiento)
);

CREATE TABLE GR01_PALLET (
    cod_pallet varchar(20)  NOT NULL,
    descripcion varchar(200)  NOT NULL,
    peso decimal(10,2)  NOT NULL,
    CONSTRAINT PK_1_PALLET PRIMARY KEY (cod_pallet)
);

CREATE TABLE GR01_POSICION (
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    tipo varchar(40)  NOT NULL,
    pos_global int  NOT NULL,
    CONSTRAINT UQ_1_posicion_pos_global UNIQUE (pos_global) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT PK_1_POSICION PRIMARY KEY (nro_posicion,nro_estanteria,nro_fila)
);

-- foreign keys
ALTER TABLE GR01_ALQUILER ADD CONSTRAINT FK_ALQUILER_CLIENTE
    FOREIGN KEY (id_cliente)
    REFERENCES GR01_CLIENTE (cuit_cuil)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_ALQUILER_POSICIONES ADD CONSTRAINT FK_ALQUILER_POSICIONES_ALQUILER
    FOREIGN KEY (id_alquiler)
    REFERENCES GR01_ALQUILER (id_alquiler)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_ALQUILER_POSICIONES ADD CONSTRAINT FK_ALQUILER_POSICIONES_POSICION
    FOREIGN KEY (nro_posicion, nro_estanteria, nro_fila)
    REFERENCES GR01_POSICION (nro_posicion, nro_estanteria, nro_fila)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_FILA ADD CONSTRAINT FK_FILA_ESTANTERIA
    FOREIGN KEY (nro_estanteria)
    REFERENCES GR01_ESTANTERIA (nro_estanteria)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_ENTRADA ADD CONSTRAINT FK_MOV_ENTRADA_ALQUILER_POSICIONES
    FOREIGN KEY (id_alquiler, nro_posicion, nro_estanteria, nro_fila)
    REFERENCES GR01_ALQUILER_POSICIONES (id_alquiler, nro_posicion, nro_estanteria, nro_fila)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_ENTRADA ADD CONSTRAINT FK_MOV_ENTRADA_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES GR01_MOVIMIENTO (id_movimiento)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_ENTRADA ADD CONSTRAINT FK_MOV_ENTRADA_PALLET
    FOREIGN KEY (cod_pallet)
    REFERENCES GR01_PALLET (cod_pallet)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_INTERNO ADD CONSTRAINT FK_MOV_INTERNO_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES GR01_MOVIMIENTO (id_movimiento)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_INTERNO ADD CONSTRAINT FK_MOV_INTERNO_MOV_INTERNO
    FOREIGN KEY (id_movimiento_interno)
    REFERENCES GR01_MOV_INTERNO (id_movimiento)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_INTERNO ADD CONSTRAINT FK_MOV_INTERNO_POSICION
    FOREIGN KEY (nro_posicion, nro_estanteria, nro_fila)
    REFERENCES GR01_POSICION (nro_posicion, nro_estanteria, nro_fila)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_SALIDA ADD CONSTRAINT FK_MOV_SALIDA_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES GR01_MOVIMIENTO (id_movimiento)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_MOV_SALIDA ADD CONSTRAINT FK_MOV_SALIDA_MOVIMIENTO_ENTRADA
    FOREIGN KEY (id_movimiento_entrada)
    REFERENCES GR01_MOV_ENTRADA (id_movimiento)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE GR01_POSICION ADD CONSTRAINT FK_POSICION_FILA
    FOREIGN KEY (nro_estanteria, nro_fila)
    REFERENCES GR01_FILA (nro_estanteria, nro_fila)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- inserts

INSERT INTO gr01_cliente VALUES (1, 'albert', 'matito', '2019-02-06');
INSERT INTO gr01_cliente VALUES (2, 'balcaldi', 'ezequiel', '2019-02-06');
INSERT INTO gr01_cliente VALUES (3, 'miguel', 'baba', '2018-03-06');
INSERT INTO gr01_cliente VALUES (4, 'gallardo', 'agustin', '2016-03-06');
INSERT INTO gr01_cliente VALUES (5, 'larrosa', 'martin nicolas', '2016-01-01');
INSERT INTO gr01_cliente VALUES (6, 'olave', 'francisco', '2015-01-02');
INSERT INTO gr01_cliente VALUES (7, 'villaverde', 'matias maximiliano', '2016-10-03');
INSERT INTO gr01_cliente VALUES (8, 'marin', 'facundo joel', '1998-01-01');
INSERT INTO gr01_cliente VALUES (10, 'soto ruiz marquez', 'juan pablo angel rodrigo', '2011-05-07');
INSERT INTO gr01_cliente VALUES (11, 'rodriguez', 'juan', '2000-05-05');
INSERT INTO gr01_cliente VALUES (12, 'gallardo', 'jose', '2018-09-09');
INSERT INTO gr01_cliente VALUES (13, 'Mairal', 'Abril', '2016-06-06');
INSERT INTO gr01_cliente VALUES (9, 'ybarra', 'gonzalo martin', '2000-05-05');
INSERT INTO gr01_cliente VALUES (14, 'berutti', 'camilo', '1998-01-01');
INSERT INTO gr01_cliente VALUES (15, 'balcaldi', 'simon', '2000-05-05');

INSERT INTO gr01_alquiler VALUES (3, 2, '2019-06-01', NULL, 1.00);
INSERT INTO gr01_alquiler VALUES (4, 3, '2016-01-01', '2018-03-06', 5.00);
INSERT INTO gr01_alquiler VALUES (5, 4, '2016-01-01', NULL, 77.00);
INSERT INTO gr01_alquiler VALUES (7, 6, '2019-05-31', NULL, 3.00);
INSERT INTO gr01_alquiler VALUES (8, 7, '2019-05-31', NULL, 77.00);
INSERT INTO gr01_alquiler VALUES (9, 8, '2016-01-01', NULL, 10.00);
INSERT INTO gr01_alquiler VALUES (11, 10, '2016-01-01', NULL, 70.00);
INSERT INTO gr01_alquiler VALUES (12, 13, '2019-05-31', NULL, 5.00);
INSERT INTO gr01_alquiler VALUES (13, 11, '2019-05-31', NULL, 3.00);
INSERT INTO gr01_alquiler VALUES (6, 5, '2019-06-01', NULL, 1.00);
INSERT INTO gr01_alquiler VALUES (14, 14, '2019-05-23', NULL, 2.00);
INSERT INTO gr01_alquiler VALUES (15, 15, '2019-05-22', '2019-05-31', 500.00);
INSERT INTO gr01_alquiler VALUES (10, 9, '2019-05-31', '2019-06-19', 1.00);
INSERT INTO gr01_alquiler VALUES (1, 1, '2019-06-01', '2019-06-09', 55.00);

INSERT INTO gr01_estanteria VALUES (1, 'superior');
INSERT INTO gr01_estanteria VALUES (2, 'B');
INSERT INTO gr01_estanteria VALUES (3, 'B');
INSERT INTO gr01_estanteria VALUES (4, 'C');
INSERT INTO gr01_estanteria VALUES (5, 'inferior');

INSERT INTO gr01_fila VALUES (1, 1, 'superior', 20.00);
INSERT INTO gr01_fila VALUES (1, 2, 'a', 22.00);
INSERT INTO gr01_fila VALUES (3, 1, 'superior', 30.00);
INSERT INTO gr01_fila VALUES (4, 1, 'superior', 30.00);
INSERT INTO gr01_fila VALUES (5, 1, 'superior', 55.00);
INSERT INTO gr01_fila VALUES (2, 5, 'inferior', 10.00);

INSERT INTO gr01_posicion VALUES (1, 1, 1, 'insecticidas', 1);
INSERT INTO gr01_posicion VALUES (4, 1, 1, 'general', 2);
INSERT INTO gr01_posicion VALUES (1, 2, 5, 'general', 3);
INSERT INTO gr01_posicion VALUES (1, 4, 1, 'general', 4);
INSERT INTO gr01_posicion VALUES (2, 5, 1, 'insecticidas', 5);
INSERT INTO gr01_posicion VALUES (7, 3, 1, 'vidrio', 6);

INSERT INTO gr01_alquiler_posiciones VALUES (1, 1, 1, 1, true);
INSERT INTO gr01_alquiler_posiciones VALUES (1, 4, 1, 1, true);
INSERT INTO gr01_alquiler_posiciones VALUES (3, 1, 1, 1, true);
INSERT INTO gr01_alquiler_posiciones VALUES (4, 4, 1, 1, true);
INSERT INTO gr01_alquiler_posiciones VALUES (12, 2, 5, 1, true);

INSERT INTO gr01_pallet VALUES ('1', 'estandar', 5.00);
INSERT INTO gr01_pallet VALUES ('2', 'pesado', 200.00);
INSERT INTO gr01_pallet VALUES ('3', '.', 5.00);
INSERT INTO gr01_pallet VALUES ('4', '.', 3.00);
INSERT INTO gr01_pallet VALUES ('5', '.', 15.00);

INSERT INTO gr01_movimiento VALUES (1, '2019-06-09 00:00:00', 'matito', 'a');
INSERT INTO gr01_movimiento VALUES (2, '2019-03-06 00:00:00', 'matito', 'a');
INSERT INTO gr01_movimiento VALUES (3, '2019-02-06 00:00:00', 'matito', 'a');
INSERT INTO gr01_movimiento VALUES (4, '2019-02-06 00:00:00', 'matito', 'c');
INSERT INTO gr01_movimiento VALUES (5, '2019-02-06 00:00:00', 'matito', 'e');
INSERT INTO gr01_movimiento VALUES (6, '2019-02-06 00:00:00', 'matito', 'f');

INSERT INTO gr01_mov_entrada VALUES (1, 'oca', 'oca', '1', 1, 1, 1, 1);
INSERT INTO gr01_mov_entrada VALUES (2, '.', '.', '3', 3, 1, 1, 1);
INSERT INTO gr01_mov_entrada VALUES (3, '.', '.', '5', 12, 2, 5, 1);
INSERT INTO gr01_mov_entrada VALUES (5, '.', '.', '4', 1, 4, 1, 1);
INSERT INTO gr01_mov_entrada VALUES (4, '.', '.', '3', 3, 1, 1, 1);

INSERT INTO gr01_mov_interno VALUES (1, 'a', 1, 1, 1, 1);
INSERT INTO gr01_mov_interno VALUES (2, 'asd', 4, 1, 1, 2);
INSERT INTO gr01_mov_interno VALUES (3, 'asd', 4, 1, 1, 3);
INSERT INTO gr01_mov_interno VALUES (4, 'asd', 7, 3, 1, 4);
INSERT INTO gr01_mov_interno VALUES (5, 'asd', 2, 5, 1, 5);


INSERT INTO gr01_mov_salida VALUES (1, '.', '.', 1);
INSERT INTO gr01_mov_salida VALUES (2, '.', '.', 2);
INSERT INTO gr01_mov_salida VALUES (3, 'd', 'd', 3);
INSERT INTO gr01_mov_salida VALUES (4, 'd', 'd', 4);
INSERT INTO gr01_mov_salida VALUES (5, 'd', 'd', 5);
