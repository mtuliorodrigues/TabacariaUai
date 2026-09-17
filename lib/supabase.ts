import { createBrowserClient } from "@supabase/ssr";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

// The publishable key is intentionally the only key sent to the browser.
export const supabase = url && key ? createBrowserClient(url, key) : null;
