import { jsonResponse, withPinAuth } from "../_shared/pin.ts";

Deno.serve((req: Request) =>
  withPinAuth(req, async ({ userId, admin }) => {
    const { data, error } = await admin
      .from("user_pins")
      .select("user_id")
      .eq("user_id", userId)
      .maybeSingle();

    if (error) {
      console.error("Unable to check PIN status:", error);
      return jsonResponse({ error: "Unable to check PIN status" }, 500);
    }

    return jsonResponse({ hasPin: data !== null });
  })
);
