/**
 * HTTPS proxy: Cloudflare Worker → AWS Python API (HTTP).
 * Lets https://bablo-bot.web.app call the backend without Mixed Content errors.
 */

const BACKEND = "http://18.197.147.209:8000";

const ALLOWED_ORIGINS = new Set([
  "https://bablo-bot.web.app",
  "https://bablo-bot.firebaseapp.com",
  "http://localhost:8080",
  "http://127.0.0.1:8080",
]);

function corsHeaders(origin) {
  const allowed = ALLOWED_ORIGINS.has(origin) ? origin : "https://bablo-bot.web.app";
  return {
    "Access-Control-Allow-Origin": allowed,
    "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept",
    "Access-Control-Allow-Credentials": "true",
    "Access-Control-Max-Age": "86400",
  };
}

export default {
  async fetch(request) {
    const origin = request.headers.get("Origin") || "";

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders(origin) });
    }

    const url = new URL(request.url);
    const backendUrl = `${BACKEND}${url.pathname}${url.search}`;

    const headers = new Headers(request.headers);
    headers.delete("host");

    try {
      const backendResponse = await fetch(backendUrl, {
        method: request.method,
        headers,
        body: request.method === "GET" || request.method === "HEAD" ? undefined : request.body,
        redirect: "follow",
      });

      const responseHeaders = new Headers(backendResponse.headers);
      for (const [key, value] of Object.entries(corsHeaders(origin))) {
        responseHeaders.set(key, value);
      }

      return new Response(backendResponse.body, {
        status: backendResponse.status,
        statusText: backendResponse.statusText,
        headers: responseHeaders,
      });
    } catch (err) {
      return new Response(
        JSON.stringify({ error: "Backend unavailable", detail: String(err) }),
        {
          status: 502,
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders(origin),
          },
        },
      );
    }
  },
};
