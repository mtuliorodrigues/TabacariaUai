"use client";

import { FormEvent, useEffect, useState } from "react";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

export default function ResetPasswordPage() {
  const [ready, setReady] = useState(false);
  const [valid, setValid] = useState(false);
  const [message, setMessage] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!supabase) return;
    supabase.auth.getUser().then(({ data, error }) => {
      setValid(!error && Boolean(data.user));
      setReady(true);
    });
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!supabase) return;
    const form = new FormData(event.currentTarget);
    const password = String(form.get("password"));
    const confirmation = String(form.get("confirmation"));
    if (password !== confirmation) return setMessage("As senhas não conferem.");
    setBusy(true);
    const { error } = await supabase.auth.updateUser({ password });
    setBusy(false);
    if (error) return setMessage(error.message);
    await supabase.auth.signOut();
    setMessage("Senha atualizada. Entre novamente com sua nova senha.");
    setValid(false);
  }

  return <main className="grid min-h-svh place-items-center bg-stone-100 p-5"><section className="w-full max-w-md rounded-2xl bg-white p-8 shadow-sm"><p className="text-xs font-bold tracking-widest text-amber-700">UAI ERP</p><h1 className="mt-2 text-2xl font-bold">Definir nova senha</h1>{!ready ? <p className="mt-4 text-sm text-stone-500">Validando o link…</p> : !valid ? <><p className="mt-4 text-sm text-stone-600">Este link expirou ou já foi usado. Solicite uma nova redefinição.</p><Link href="/" className="mt-6 inline-block text-sm font-semibold text-amber-700">Voltar para entrar</Link></> : <form onSubmit={submit} className="mt-6 space-y-4"><label className="block text-sm font-semibold">Nova senha<input name="password" type="password" minLength={12} autoComplete="new-password" required className="mt-1.5 w-full rounded-lg border border-stone-200 px-3 py-2.5 font-normal outline-none focus:border-amber-500" /></label><label className="block text-sm font-semibold">Confirmar nova senha<input name="confirmation" type="password" minLength={12} autoComplete="new-password" required className="mt-1.5 w-full rounded-lg border border-stone-200 px-3 py-2.5 font-normal outline-none focus:border-amber-500" /></label><p className="text-xs text-stone-500">Use ao menos 12 caracteres.</p>{message && <p className="text-sm text-red-700">{message}</p>}<button disabled={busy} className="w-full rounded-lg bg-stone-950 py-3 font-bold text-white disabled:opacity-60">{busy ? "Atualizando…" : "Salvar nova senha"}</button></form>}</section></main>;
}
