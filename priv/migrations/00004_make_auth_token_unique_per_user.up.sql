-- A user should only have one auth token at a time regardless or where they are
-- logged in from, this also means we don't have to worry about deleting old tokens
CREATE UNIQUE INDEX auth_tk_user_unique ON auth_tokens (user_id);
