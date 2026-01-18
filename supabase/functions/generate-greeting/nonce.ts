/**
 * Nonce validation module for preventing replay attacks
 *
 * Uses client-generated nonces with format: {uuid}:{timestamp_ms}
 * Validates nonces for uniqueness and freshness
 * Stores used nonces in Supabase database (persists across Edge Function isolates)
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// Validation constants
const NONCE_MAX_AGE_MS = 5 * 60 * 1000        // 5 minutes (allows clock drift)
const NONCE_FUTURE_TOLERANCE_MS = 60 * 1000   // 1 minute future tolerance

// UUID format regex (lowercased)
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

interface NonceValidationResult {
  valid: boolean
  error?: string
  code?: string
}

/**
 * Validate a nonce for freshness and uniqueness
 * Uses Supabase database to track used nonces (persists across isolates)
 * @param nonce - Format: "{uuid}:{timestamp_ms}"
 * @param userId - User ID to scope the nonce
 * @returns Validation result with error details if invalid
 */
export async function validateNonce(nonce: string, userId: string): Promise<NonceValidationResult> {
  // 1. Parse nonce format
  const parts = nonce.split(':')
  if (parts.length !== 2) {
    return {
      valid: false,
      error: "Invalid nonce format. Expected: {uuid}:{timestamp}",
      code: "INVALID_FORMAT"
    }
  }

  const [uuid, timestampStr] = parts

  // 2. Validate UUID format
  if (!UUID_REGEX.test(uuid)) {
    return {
      valid: false,
      error: "Invalid UUID format in nonce",
      code: "INVALID_FORMAT"
    }
  }

  // 3. Validate timestamp
  const timestamp = parseInt(timestampStr, 10)
  if (isNaN(timestamp)) {
    return {
      valid: false,
      error: "Invalid timestamp in nonce",
      code: "INVALID_FORMAT"
    }
  }

  const now = Date.now()
  const age = now - timestamp

  // Check if timestamp is too old
  if (age > NONCE_MAX_AGE_MS) {
    return {
      valid: false,
      error: `Nonce timestamp too old (max age: ${NONCE_MAX_AGE_MS / 1000}s)`,
      code: "EXPIRED_TIMESTAMP"
    }
  }

  // Check if timestamp is in the future (clock skew tolerance)
  if (age < -NONCE_FUTURE_TOLERANCE_MS) {
    return {
      valid: false,
      error: "Nonce timestamp is in the future",
      code: "FUTURE_TIMESTAMP"
    }
  }

  // 4. Check if nonce already used via database (works across isolates)
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!  // Use service role for unrestricted access
  )

  const nonceKey = `${userId}:${uuid}`
  const expiresAt = new Date(now + 60 * 60 * 1000).toISOString()  // 1 hour from now

  try {
    // Try to insert nonce - if it already exists, this will fail
    const { error } = await supabase
      .from('used_nonces')
      .insert({
        nonce_key: nonceKey,
        user_id: userId,
        expires_at: expiresAt
      })

    if (error) {
      // Check if error is due to duplicate key (replay detected)
      if (error.code === '23505') {  // PostgreSQL unique violation code
        return {
          valid: false,
          error: "Nonce has already been used (replay detected)",
          code: "REPLAY_DETECTED"
        }
      }

      // Other database error
      console.error("[Nonce] Database error:", error)
      // Allow request to proceed on database errors (fail open for availability)
      return { valid: true }
    }

    return { valid: true }

  } catch (err) {
    console.error("[Nonce] Exception during validation:", err)
    // Fail open on exceptions
    return { valid: true }
  }
}
