import { jsonResponse, withPinAuth } from "../_shared/pin.ts";

Deno.serve((req: Request) =>
  withPinAuth(req, async ({ userId, admin }) => {
    const { error } = await admin
      .from("user_pins")
      .delete()
      .eq("user_id", userId);

    if (error) {
      console.error("Unable to remove PIN:", error);
      return jsonResponse({ error: "Unable to remove PIN" }, 500);
    }

    return jsonResponse({ success: true });
  })
);
