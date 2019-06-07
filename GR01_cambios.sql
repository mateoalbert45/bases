-- B)A)
ALTER TABLE GR01_alquiler add constraint CK_01_fechaAlquiler
check(
fecha_desde <= fecha_hasta);
--UPDATE GR01_alquiler set fecha_desde = '01-05-2019', fecha_hasta = '01-04-2019' where id_alquiler = 1;

-- B)B)
CREATE FUNCTION TRFN_1_pesomaximo () RETURNS trigger as $body$
BEGIN
   IF (select 1
       from GR01_pallet p join GR01_mov_entrada mv on(p.cod_pallet = mv.cod_pallet)
        join GR01_alquiler_posiciones ap on (mv.id_alquiler = ap.id_alquiler)
        join GR01_posicion pos on (ap.nro_posicion = pos.nro_posicion and ap.nro_estanteria
      = pos.nro_estanteria and ap.nro_fila = pos.nro_fila)
     join GR01_fila f on(pos.nro_estanteria = f.nro_estanteria and pos.nro_fila = f.nro_fila)
     Where f.nro_estanteria = new.nro_estanteria and f.nro_fila = new.nro_fila
     group by p.cod_pallet,f.peso_max_kg
     having sum(p.peso) > f.peso_max_kg) THEN
     RAISE EXCEPTION 'error de peso';
     END IF;
   return new;
   END;
   $body$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_1_fila_pesomaximo AFTER INSERT OR UPDATE OF nro_fila, nro_estanteria ON gr01_fila FOR EACH ROW EXECUTE PROCEDURE trfn_1_pesomaximo();
CREATE TRIGGER tr_1_mov_entrada_pesomaximo AFTER INSERT OR UPDATE OF nro_fila, nro_estanteria, cod_pallet ON gr01_mov_entrada FOR EACH ROW EXECUTE PROCEDURE trfn_1_pesomaximo();
CREATE TRIGGER tr_1_mov_interno_pesomaximo AFTER INSERT OR UPDATE OF nro_fila, nro_estanteria ON gr01_mov_interno FOR EACH ROW EXECUTE PROCEDURE trfn_1_pesomaximo();
CREATE TRIGGER tr_1_posicion_pesomaximo AFTER INSERT OR UPDATE OF nro_fila, nro_estanteria ON gr01_posicion FOR EACH ROW EXECUTE PROCEDURE trfn_1_pesomaximo();
CREATE TRIGGER tr_1_alquiler_posiciones_pesomaximo AFTER INSERT OR UPDATE OF nro_fila, nro_estanteria ON gr01_alquiler_posiciones FOR EACH ROW EXECUTE PROCEDURE trfn_1_pesomaximo();
-- UPDATE GR01_mov_entrada set cod_pallet = 2 where id_alquiler = 1;
-- INSERT INTO GR01_mov_entrada VALUES (6, 'oca', 'oca', 2, 1, 1 , 1, 1);
--B)C)
alter table GR01_posicion add constraint CK_01_posicion_TipoValido
check(tipo IN ('general','vidrio','insecticidas','inflamable'));
--UPDATE GR01_posicion set tipo = '123456' where pos_global = 1;
--INSERT INTO GR01_posicion VALUES(1, 1, 1, ' 123456', 7);

--C)A)
CREATE FUNCTION fn_01_listaposlibres(fecha date)
    returns TABLE(nro_fila integer, nro_estanteria integer, nro_posicion integer)
    language plpgsql
as
$$
BEGIN
RETURN QUERY SELECT p.nro_posicion,p.nro_estanteria,p.nro_fila
      FROM  GR01_posicion p join GR01_alquiler_posiciones ap on(p.nro_posicion = ap.nro_posicion) join GR01_alquiler a on (ap.id_alquiler = a.id_alquiler)
      where p.nro_posicion not in (select ap1.nro_posicion from GR01_alquiler a1 join GR01_alquiler_posiciones ap1 on (a1.id_alquiler = ap1.id_alquiler)
      where fecha >= a.fecha_desde  and  fecha<= a.fecha_hasta ) and a.fecha_hasta is not null;
END;
$$;
--C)B)
CREATE FUNCTION fn_01_clientesvencimiento(dias integer)
    returns TABLE(cuit_cuil integer, apellido character varying, nombre character varying, fecha_hasta date)
    language plpgsql
as
$$
BEGIN
RETURN QUERY SELECT c.cuit_cuil,c.apellido,c.nombre,a.fecha_hasta
      FROM gr01_cliente c join gr01_alquiler a on (c.cuit_cuil = a.id_cliente)
   where  (NOW() < a.fecha_hasta) and (DATE_PART('day', a.fecha_hasta - NOW()) < dias);
      END;
$$;

--D)A)
CREATE VIEW GR01_estado_posicion as
  select ap.nro_posicion , ap.nro_estanteria , ap.nro_fila, ap.estado,
  CASE
  WHEN ap.estado = true THEN DATE_PART('day', fecha_hasta) - DATE_PART('day', fecha_desde)
  END as "dias restantes"
  from GR01_alquiler_posiciones ap join GR01_alquiler a on (ap.id_alquiler = a.id_alquiler);
--D)B)
CREATE VIEW GR01_clientes_mas_gastaron as
select id_cliente, sum(
  CASE
  WHEN fecha_hasta is null THEN (CURRENT_DATE - fecha_desde) * importe_dia
  else (fecha_hasta - fecha_desde) *importe_dia
  END ) as cantidad
  from GR01_alquiler
  where fecha_desde <= NOW()
  and fecha_desde >= date('now') - interval '1 year'    and fecha_desde >= date('now') - interval '1 year'
  group by id_cliente
  order by cantidad DESC
  limit 10;
--E) Funciones de la página
CREATE FUNCTION fn_01_listaposocupadas(id integer)
    returns TABLE(id_cliente integer, nro_estanteria integer, nro_posicion integer, nro_fila integer)
    language plpgsql
as
$$
BEGIN
RETURN QUERY  SELECT a.id_cliente, ap.nro_estanteria, ap.nro_posicion, ap.nro_fila
      FROM  GR01_alquiler a join GR01_alquiler_posiciones ap on (a.id_alquiler = ap.id_alquiler)
      where (CURRENT_DATE >= a.fecha_desde  and  CURRENT_DATE  <= a.fecha_hasta or a.fecha_hasta is null) and a.id_cliente = id;
END;
$$;
