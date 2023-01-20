### PgBouncer Docker image

This image is patched with https://github.com/pgbouncer/pgbouncer/pull/764

Check for more info: https://www.2ndquadrant.com/en/blog/pg-phriday-securing-pgbouncer/

#### Prepare database

```
CREATE USER pgbouncer WITH PASSWORD 'changeme';
```

```
CREATE SCHEMA pgbouncer AUTHORIZATION pgbouncer;
```

```
CREATE OR REPLACE FUNCTION pgbouncer.get_auth(p_usename TEXT)
RETURNS TABLE(username TEXT, password TEXT) AS
$$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;
 
    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
     WHERE usename = p_usename;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

```
REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pgbouncer.get_auth(p_usename TEXT) TO pgbouncer;
```
