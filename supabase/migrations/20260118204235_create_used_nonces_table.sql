-- Create table for tracking used nonces to prevent replay attacks
CREATE TABLE IF NOT EXISTS used_nonces (
    nonce_key TEXT PRIMARY KEY,  -- Format: "{userId}:{uuid}"
    user_id UUID NOT NULL,       -- User ID for indexing
    expires_at TIMESTAMPTZ NOT NULL,  -- When this nonce expires
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster cleanup queries
CREATE INDEX idx_used_nonces_expires_at ON used_nonces(expires_at);

-- Index for user-specific queries
CREATE INDEX idx_used_nonces_user_id ON used_nonces(user_id);

-- Enable Row Level Security
ALTER TABLE used_nonces ENABLE ROW LEVEL SECURITY;

-- Policy: Service role can do everything (Edge Functions use service role key)
CREATE POLICY "Service role full access" ON used_nonces
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Comment explaining cleanup strategy:
-- Expired nonces can be cleaned up via:
-- DELETE FROM used_nonces WHERE expires_at < NOW();
