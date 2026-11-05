CREATE OR REPLACE FUNCTION public.record_pin_failure(p_user_id uuid)
RETURNS TABLE(failed_attempts integer, locked_until timestamptz)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_attempts integer;
  v_locked_until timestamptz;
BEGIN
  SELECT p.failed_attempts, p.locked_until
  INTO v_attempts, v_locked_until
  FROM public.user_pins AS p
  WHERE p.user_id = p_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PIN record not found';
  END IF;

  IF v_locked_until IS NOT NULL AND v_locked_until > pg_catalog.now() THEN
    RETURN QUERY SELECT v_attempts, v_locked_until;
    RETURN;
  END IF;

  v_attempts := COALESCE(v_attempts, 0) + 1;
  IF v_attempts >= 5 THEN
    v_attempts := 0;
    v_locked_until := pg_catalog.now() + INTERVAL '1 minute';
  ELSE
    v_locked_until := NULL;
  END IF;

  UPDATE public.user_pins AS p
  SET failed_attempts = v_attempts,
      locked_until = v_locked_until
  WHERE p.user_id = p_user_id;

  RETURN QUERY SELECT v_attempts, v_locked_until;
END;
$$;

REVOKE ALL ON FUNCTION public.record_pin_failure(uuid)
FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_pin_failure(uuid) TO service_role;
