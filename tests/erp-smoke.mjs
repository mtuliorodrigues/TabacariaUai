import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

test("a interface fonte contém os módulos fundamentais do ERP", async () => {
  const page = await readFile(new URL("../app/page.tsx", import.meta.url), "utf8");
  for (const sectionName of ["Visão geral", "Clientes", "Produtos", "Estoque", "Vendas"]) {
    assert.match(page, new RegExp(sectionName));
  }
  assert.match(page, /Novo cliente/);
  assert.match(page, /Novo produto/);
  assert.match(page, /supabase/);
});

test("o domínio inicial separa clientes de produtos", async () => {
  const domain = await readFile(new URL("../lib/erp.ts", import.meta.url), "utf8");
  assert.match(domain, /export type Customer/);
  assert.match(domain, /export type Product/);
});

test("a recuperação usa callback SSR dedicado", async () => {
  const page = await readFile(new URL("../app/page.tsx", import.meta.url), "utf8");
  const callback = await readFile(new URL("../app/auth/reset-password/confirm/route.ts", import.meta.url), "utf8");
  assert.match(page, /resetPasswordForEmail/);
  assert.match(page, /auth\/reset-password\/confirm/);
  assert.match(callback, /exchangeCodeForSession/);
  assert.match(callback, /auth\/reset-password/);
});
