import {
  jsonResponse,
  maxPinAttempts,
  pinLockoutMilliseconds,
  readPin,
  verifyPinHash,
  withPinAuth,
} from "../_shared/pin.ts";

Deno.serve((req: Request) =>
  withPinAuth(req, async ({ userId, admin }) => {
    const pin = await readPin(req);
    const { data: row, error } = await admin
      .from("user_pins")
      .select("pin_hash, failed_attempts, locked_until")
      .eq("user_id", userId)
      .maybeSingle();

    if (error) {
      console.error("Unable to load PIN:", error);
      return jsonResponse({ error: "Unable to verify PIN" }, 500);
    }

    if (!row) {
      return jsonResponse({ success: false, hasPin: false });
    }

    const lockedUntil = row.locked_until
      ? new Date(row.locked_until).getTime()
      : 0;
    if (lockedUntil > Date.now()) {
      return jsonResponse({ success: false, locked: true });
    }

    if (await verifyPinHash(pin, row.pin_hash)) {
      const { error: resetError } = await admin
        .from("user_pins")
        .update({ failed_attempts: 0, locked_until: null })
        .eq("user_id", userId);

      if (resetError) {
        console.error("Unable to clear PIN failures:", resetError);
        return jsonResponse({ error: "Unable to verify PIN" }, 500);
      }

      return jsonResponse({ success: true });
    }

    const { data: attempts, error: attemptError } = await admin.rpc(
      "record_pin_failure",
      { p_user_id: userId },
    );

    if (attemptError || !Array.isArray(attempts) || attempts.length === 0) {
      console.error("Unable to record failed PIN attempt:", attemptError);
      return jsonResponse({ error: "Unable to verify PIN" }, 500);
    }

    const currentLock = attempts[0].locked_until
      ? new Date(attempts[0].locked_until).getTime()
      : 0;
    const isLocked = currentLock > Date.now();
    const attemptCount = Number(attempts[0].failed_attempts);

    return jsonResponse({
      success: false,
      locked: isLocked || attemptCount >= maxPinAttempts,
      ...(isLocked
        ? { retryAfterSeconds: Math.ceil((currentLock - Date.now()) / 1000) }
        : {}),
      ...(isLocked ? {} : { attemptsLeft: maxPinAttempts - attemptCount }),
      lockoutMilliseconds: pinLockoutMilliseconds,
    });
  })
);
