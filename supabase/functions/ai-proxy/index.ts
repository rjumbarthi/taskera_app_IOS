// Supabase Edge Function — ai-proxy
// Proxies AI requests to Claude (primary) then OpenAI (fallback).
// API keys are stored as Edge Function secrets, never exposed to the client.
//
// Deploy:  supabase functions deploy ai-proxy
// Secrets: supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//          supabase secrets set OPENAI_API_KEY=sk-...

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const PROMPTS: Record<string, (content: string) => string> = {
  summarize_note: (c) =>
    `Summarize this note in 1-2 sentences, focusing on action items:\n\n${c}`,

  score_task: (c) =>
    `Rate the urgency and importance of this task on a scale of 1-10, and suggest ` +
    `which Eisenhower quadrant it belongs to (Q1=urgent+important, Q2=not-urgent+important, ` +
    `Q3=urgent+not-important, Q4=not-urgent+not-important).\n\nTask: ${c}\n\n` +
    `Respond in JSON only: {"urgency":N,"importance":N,"quadrant":N,"reason":"..."}`,

  brain_dump: (c) =>
    `Organize these brain-dump thoughts into Eisenhower quadrants and extract clear tasks:\n\n${c}\n\n` +
    `Respond in JSON only: {"q1":[...],"q2":[...],"q3":[...],"q4":[...],"summary":"..."}`,

  insights: (c) =>
    `Based on these tasks and notes from a productivity app:\n\n${c}\n\n` +
    `Provide 2-3 brief, specific, actionable insights about patterns, what to focus on, ` +
    `and what the user might be avoiding. ` +
    `Respond in JSON only: {"insights":[{"title":"...","detail":"..."}]}`,

  suggest_context: (c) =>
    `You are a smart assistant in a productivity app. The user wrote this:\n\n"${c}"\n\n` +
    `Identify the main event, project, or goal. Suggest specific, actionable items for it.\n\n` +
    `Quadrant rules: 1=urgent+important (due <1 week), 2=not-urgent+important (planned, 1+ weeks), ` +
    `3=urgent+not-important (delegate if possible), 4=not-urgent+not-important (someday/skip).\n\n` +
    `Suggest 4-6 tasks, 6-10 checklist items, 1-2 goals. Keep each item under 8 words.\n\n` +
    `Respond in JSON only (no markdown):\n` +
    `{"context":"short label e.g. Trip to USA in July","tasks":[{"title":"...","quadrant":2}],"checklist":["item1","item2"],"goals":["goal1"]}`,
};

async function callClaude(prompt: string): Promise<string> {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": Deno.env.get("ANTHROPIC_API_KEY") ?? "",
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1024,
      messages: [{ role: "user", content: prompt }],
    }),
  });
  if (!res.ok) throw new Error(`Claude ${res.status}`);
  const data = await res.json();
  return data.content?.[0]?.text ?? "";
}

async function callOpenAI(prompt: string): Promise<string> {
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${Deno.env.get("OPENAI_API_KEY") ?? ""}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      max_tokens: 1024,
      messages: [{ role: "user", content: prompt }],
    }),
  });
  if (!res.ok) throw new Error(`OpenAI ${res.status}`);
  const data = await res.json();
  return data.choices?.[0]?.message?.content ?? "";
}

Deno.serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { action, content } = await req.json();
    const promptFn = PROMPTS[action as string];
    if (!promptFn) {
      return new Response(JSON.stringify({ error: "Unknown action" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const prompt = promptFn(content as string);
    let result = "";

    // Try Claude first, fall back to OpenAI
    try {
      result = await callClaude(prompt);
    } catch {
      result = await callOpenAI(prompt);
    }

    return new Response(JSON.stringify({ result }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
