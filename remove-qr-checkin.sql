-- Run this once ONLY if your Supabase project was set up before QR check-in was removed.
-- It deletes the old check-in function and its two tables. New projects do not need it.
drop function if exists public.check_in(text);
drop table if exists event_checkins;
drop table if exists event_codes;
