import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "npm:@supabase/supabase-js@2/cors";

export const maxPinAttempts = 5;
export const pinLockoutMilliseconds = 60_000;

export class PinRequestError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

export type PinContext = {
  userId: string;
  admin: SupabaseClient;
};

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

export async function withPinAuth(
  req: Request,
  handler: (context: PinContext) => Promise<Response>,
): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authorization = req.headers.get("Authorization");
    if (!authorization) {
      throw new PinRequestError("Unauthorized", 401);
    }

    const url = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !anonKey || !serviceRoleKey) {
      throw new Error("Supabase function environment is not configured");
    }

    const authClient = createClient(url, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const {
      data: { user },
      error: authError,
    } = await authClient.auth.getUser();

    if (authError || !user) {
      throw new PinRequestError("Unauthorized", 401);
    }

    const admin = createClient(url, serviceRoleKey);
    return await handler({ userId: user.id, admin });
  } catch (error) {
    if (error instanceof PinRequestError) {
      return jsonResponse({ error: error.message }, error.status);
    }

    console.error("PIN function error:", error);
    return jsonResponse({ error: "Unable to process PIN request" }, 500);
  }
}

export async function readPin(req: Request): Promise<string> {
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    throw new PinRequestError("A valid PIN is required", 400);
  }

  const pin = (body as { pin?: unknown } | null)?.pin;
  if (typeof pin !== "string" || !/^\d{4}$/.test(pin)) {
    throw new PinRequestError("PIN must contain exactly four digits", 400);
  }

  return pin;
}

const hashIterations = 210_000;
const saltLength = 16;
const encoder = new TextEncoder();

function encodeBase64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/, "");
}

function decodeBase64Url(value: string): Uint8Array {
  const base64 = value.replaceAll("-", "+").replaceAll("_", "/");
  const binary = atob(base64.padEnd(Math.ceil(base64.length / 4) * 4, "="));
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

async function derivePinHash(
  pin: string,
  salt: Uint8Array,
  iterations: number,
): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(pin),
    "PBKDF2",
    false,
    ["deriveBits"],
  );
  const bits = await crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      salt,
      iterations,
      hash: "SHA-256",
    },
    key,
    256,
  );
  return new Uint8Array(bits);
}

export async function hashPin(pin: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(saltLength));
  const hash = await derivePinHash(pin, salt, hashIterations);
  return `pbkdf2-sha256$${hashIterations}$${encodeBase64Url(salt)}$${encodeBase64Url(hash)}`;
}

export async function verifyPinHash(
  pin: string,
  encoded: string,
): Promise<boolean> {
  const [algorithm, iterationsText, saltText, hashText, extra] = encoded.split("$");
  const iterations = Number(iterationsText);
  if (
    algorithm !== "pbkdf2-sha256" ||
    !Number.isInteger(iterations) ||
    iterations < 10_000 ||
    iterations > 1_000_000 ||
    !saltText ||
    !hashText ||
    extra !== undefined
  ) {
    return false;
  }

  try {
    const salt = decodeBase64Url(saltText);
    const expected = decodeBase64Url(hashText);
    if (salt.length !== saltLength || expected.length !== 32) return false;

    const actual = await derivePinHash(pin, salt, iterations);
    let difference = 0;
    for (let i = 0; i < expected.length; i++) {
      difference |= expected[i] ^ actual[i];
    }
    return difference === 0;
  } catch {
    return false;
  }
}

export { jsonResponse };
