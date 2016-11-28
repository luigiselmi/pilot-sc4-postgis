-- Function: fn_mapmatch(character varying, character varying, integer, integer)

-- DROP FUNCTION fn_mapmatch(character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION fn_mapmatch(IN tempdataname character varying, IN tempprocname character varying, IN meters_buffer integer, IN ncand integer)
  RETURNS TABLE(rownum bigint, device_random_id integer, recorded_timestamp text, lon text, lat text, altitude text, speed integer, orientation double precision, transfer integer, osmids bigint[], distances double precision[], cpoints text[]) AS
$BODY$
BEGIN

IF (((select tempdataname LIKE 'temp_gps_data_%')=false) OR ((select tempprocname LIKE 'temp_gps_proc_%')=false)) THEN
	RAISE NOTICE '%', 'Table name prefix is hardcoded and should not be changed. Cannot continue.';
	return;
END IF;

--Create a temp table named tempprocname to store geometry and geography variables and process. 
--We need both because geometry is compatible with ST_ClosestPoint while geography can return the spatial results in meters
EXECUTE 'CREATE TEMP TABLE ' || quote_ident(tempprocname) ||
'(
  device_random_id integer,  
  recorded_timestamp text,
  lon double precision,
  lat double precision,
  altitude text,
  speed integer,
  orientation double precision,
  transfer integer,  
  geom geometry,
  geog geography
)
WITH (
  OIDS=FALSE
);

--Create indexes

CREATE INDEX '  || quote_ident(tempprocname) || '_device_idx
	ON '  || quote_ident(tempprocname) || '
USING btree
(device_random_id ASC,recorded_timestamp ASC);

--Create spatial indexes

CREATE INDEX '  || quote_ident(tempprocname) || 'idx_data_gpswithspatial_geog
	ON '  || quote_ident(tempprocname) || '
USING gist
(geog);

CREATE INDEX '  || quote_ident(tempprocname) || 'idx_data_gpswithspatial_geom
	ON '  || quote_ident(tempprocname) || '
USING gist
(geom);
';

--Insert the GPS dataset into the newly created temp table for further processing
EXECUTE 'INSERT INTO ' || quote_ident(tempprocname) 
	|| ' SELECT device_random_id, recorded_timestamp, lon, lat, altitude, speed, orientation, transfer, geometry(ST_SetSRID(ST_MakePoint(lon,lat),4326)),geography(ST_Transform(ST_SetSRID(ST_MakePoint(lon,lat),4326),4326)) FROM ' 
	|| quote_ident(tempdataname);

--Drop data table (without spatial fields) created by R
EXECUTE 'DROP TABLE ' || quote_ident(tempdataname);

--VACUUM ANALYZE tempprocname
--EXECUTE 'VACUUM ANALYZE ' || quote_ident(tempprocname);
--ERROR: VACUUM cannot run inside a transaction block 25001

--Execute calculations
return query
EXECUTE 'SELECT 
		row_number() over (order by recorded_timestamp,device_random_id nulls last),
		' || quote_ident(tempprocname) || '.device_random_id,
		' || quote_ident(tempprocname) || '.recorded_timestamp,
		' || quote_ident(tempprocname) || '.lon::text,
		' || quote_ident(tempprocname) || '.lat::text,		
		' || quote_ident(tempprocname) || '.altitude::text,
		' || quote_ident(tempprocname) || '.speed,
		' || quote_ident(tempprocname) || '.orientation,
		' || quote_ident(tempprocname) || '.transfer,
		array_agg(ways_spatial.id ORDER BY ST_Distance(' || quote_ident(tempprocname) || '.geog,ways_spatial.geog), ways_spatial.id),
		array_agg(ST_Distance(' || quote_ident(tempprocname) || '.geog,ways_spatial.geog) ORDER BY ST_Distance(' || quote_ident(tempprocname) || '.geog,ways_spatial.geog),ways_spatial.id),
		array_agg(ST_Y(ST_ClosestPoint(ways_spatial.geom,' || quote_ident(tempprocname) || '.geom))::text  || '' '' || ST_X(ST_ClosestPoint(ways_spatial.geom,' || quote_ident(tempprocname) || '.geom))::text ORDER BY ST_Distance(' || quote_ident(tempprocname) || '.geog,ways_spatial.geog),ways_spatial.id)
		
	FROM ' || quote_ident(tempprocname) || '
		INNER JOIN ways_spatial ON 
			(ways_spatial.id =
			ANY(
				(SELECT array(select id FROM ways_spatial WHERE ST_DWithin(' || quote_ident(tempprocname) || '.geog,ways_spatial.geog,' || meters_buffer || ') 
					ORDER BY ST_Distance(' || quote_ident(tempprocname) || '.geog,ways_spatial.geog) ASC LIMIT ' || ncand || '))::integer[]
			))
	GROUP BY ' 
		   || quote_ident(tempprocname) || '.recorded_timestamp,'
		   || quote_ident(tempprocname) || '.device_random_id,' 		   
		   || quote_ident(tempprocname) || '.lon,'
		   || quote_ident(tempprocname) || '.lat,'
		   || quote_ident(tempprocname) || '.altitude::text,'
		   || quote_ident(tempprocname) || '.speed,'
		   || quote_ident(tempprocname) || '.orientation,'
		   || quote_ident(tempprocname) || '.transfer
		   
	ORDER BY recorded_timestamp,device_random_id';
		

--Drop temp processing table
EXECUTE 'DROP TABLE ' || quote_ident(tempprocname);

EXCEPTION WHEN others THEN	
	--Try to clean up
	EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tempdataname);
	EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tempprocname);	
	--Raise notice
	RAISE NOTICE '% % %', 'Oops..Unfortunatelly something went wrong:', SQLERRM, SQLSTATE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fn_mapmatch(character varying, character varying, integer, integer)
  OWNER TO postgres;
