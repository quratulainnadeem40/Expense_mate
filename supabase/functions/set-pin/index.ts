import { hashPin, jsonResponse, readPin, withPinAuth } from "../_shared/pin.ts";

Deno.serve((req: Request) =>
  withPinAuth(req, async ({ userId, admin }) => {
    const pin = await readPin(req);
    const pinHash = await hashPin(pin);
    const { error } = await admin.from("user_pins").upsert(
      {
        user_id: userId,
        pin_hash: pinHash,
        failed_attempts: 0,
        locked_until: null,
        created_at: new Date().toISOString(),
      },
      { onConflict: "user_id" },
    );

    if (error) {
      console.error("Unable to save PIN:", error);
      return jsonResponse({ error: "Unable to save PIN" }, 500);
    }

    return jsonResponse({ success: true });
  })
);
