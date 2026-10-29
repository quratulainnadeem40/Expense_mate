// Supabase Edge Function: send-security-alert
//
// The app calls this after a sign-in, and when the PIN keypad locks
// after too many wrong attempts. The email provider key stays here on
// the server, never inside the APK.
//
// Deploy:
//   supabase functions deploy send-security-alert
//
// Secrets it needs:
//   supabase secrets set RESEND_API_KEY=re_xxx
//   supabase secrets set ALERT_FROM="Expense Mate <alerts@yourdomain.com>"

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ALERT_FROM = Deno.env.get("ALERT_FROM") ?? "Expense Mate <onboarding@resend.dev>";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function formatWhen(iso: string): string {
  try {
    return new Date(iso).toUTCString();
  } catch {
    return iso;
  }
}

function buildEmail(event: string, device: string, when: string, attempts: number) {
  const isLockout = event === "pin_lockout";

  const subject = isLockout
    ? "Wrong PIN attempts on your Expense Mate account"
    : "New sign-in to your Expense Mate account";

  const heading = isLockout ? "Someone could not unlock your app" : "You signed in";

  const line = isLockout
    ? `There were ${attempts} wrong PIN attempts, so the app locked itself for a minute.`
    : "Your account was used to sign in to Expense Mate.";

  const advice = isLockout
    ? "If this was not you, open the app, change your PIN, and change your account password."
    : "If this was not you, change your account password straight away.";

  const html = `
<!doctype html>
<html>
  <body style="margin:0;padding:24px;background:#f4f6f4;font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif;">
    <div style="max-width:520px;margin:0 auto;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e6e8e6;">
      <div style="background:${isLockout ? "#B3261E" : "#2EA44F"};padding:20px 24px;">
        <p style="margin:0;color:#ffffff;font-size:18px;font-weight:700;">${heading}</p>
      </div>

      <div style="padding:22px 24px;">
        <p style="margin:0 0 16px;font-size:14px;line-height:1.6;color:#374151;">${line}</p>

        <table style="width:100%;border-collapse:collapse;font-size:13px;color:#374151;">
          <tr>
            <td style="padding:7px 0;color:#6b7280;width:90px;">Device</td>
            <td style="padding:7px 0;font-weight:600;">${device}</td>
          </tr>
          <tr>
            <td style="padding:7px 0;color:#6b7280;">Time (UTC)</td>
            <td style="padding:7px 0;font-weight:600;">${when}</td>
          </tr>
        </table>

        <div style="margin-top:18px;padding:12px 14px;background:${isLockout ? "#fdecea" : "#eaf3de"};border-radius:10px;">
          <p style="margin:0;font-size:13px;line-height:1.6;color:#374151;">${advice}</p>
        </div>

        <p style="margin:18px 0 0;font-size:11.5px;color:#9ca3af;">
          You are receiving this because security alerts are on for your
          Expense Mate account.
        </p>
      </div>
    </div>
  </body>
</html>`;

  return { subject, html };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  try {
    // The caller must be a signed-in user. Without this check anyone
    // could hit the endpoint and send mail to any address.
    const authHeader = req.headers.get("Authorization") ?? "";

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userError } = await supabase.auth.getUser();

    if (userError || !userData?.user) {
      return new Response(
        JSON.stringify({ error: "Not signed in" }),
        { status: 401, headers: { ...CORS, "Content-Type": "application/json" } },
      );
    }

    const body = await req.json();

    const event = String(body.event ?? "login_success");
    const device = String(body.device ?? "Unknown device");
    const when = formatWhen(String(body.at ?? new Date().toISOString()));
    const attempts = Number(body.attempts ?? 0);

    // Always mail the address on the account, never one sent in the
    // request. Otherwise this becomes a way to send mail to strangers.
    const to = userData.user.email;

    if (!to) {
      return new Response(
        JSON.stringify({ error: "Account has no email" }),
        { status: 400, headers: { ...CORS, "Content-Type": "application/json" } },
      );
    }

    const { subject, html } = buildEmail(event, device, when, attempts);

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ from: ALERT_FROM, to: [to], subject, html }),
    });

    if (!res.ok) {
      const detail = await res.text();
      return new Response(
        JSON.stringify({ error: "Email provider refused", detail }),
        { status: 502, headers: { ...CORS, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ ok: true }),
      { headers: { ...CORS, "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...CORS, "Content-Type": "application/json" } },
    );
  }
});
