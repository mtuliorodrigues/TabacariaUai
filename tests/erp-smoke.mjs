import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

test("build estático contém os fluxos críticos do ERP", async () => {
  const html = await readFile(new URL("../dist/index.html", import.meta.url), "utf8");
  assert.match(html, /supabase/i);
  assert.match(html, /accountMenu/);
  assert.match(html, /stopImmediatePropagation/);
  assert.match(html, /logout/);
  assert.match(html, /products/i);
  assert.match(html, /clients/i);
});
