-- Table: ways_spatial

-- DROP TABLE ways_spatial;

CREATE TABLE ways_spatial
(
  id bigint NOT NULL,
  version integer NOT NULL,
  user_id integer NOT NULL,
  tstamp timestamp without time zone NOT NULL,
  changeset_id bigint NOT NULL,
  tags hstore,
  nodes bigint[],
  geom geometry,
  geog geography,
  CONSTRAINT pk_ways_spatial PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ways_spatial
  OWNER TO postgres;

-- Index: idx_ways_spatial_geog

-- DROP INDEX idx_ways_spatial_geog;

CREATE INDEX idx_ways_spatial_geog
  ON ways_spatial
  USING gist
  (geog);

-- Index: idx_ways_spatial_geom

-- DROP INDEX idx_ways_spatial_geom;

CREATE INDEX idx_ways_spatial_geom
  ON ways_spatial
  USING gist
  (geom);

-- INSERT data (get only roads)

INSERT INTO ways_spatial
	SELECT id, version, user_id, tstamp, changeset_id, tags, nodes, linestring, geography(ST_Transform(linestring,4326))
	FROM ways
	WHERE tags->'highway' like '%';