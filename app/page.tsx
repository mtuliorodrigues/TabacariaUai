"use client";

import { useState } from "react";
import { Box, CircleUserRound, Grid2X2, Instagram, Package, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Sidebar, SidebarContent, SidebarFooter, SidebarGroup, SidebarGroupContent, SidebarHeader, SidebarInset, SidebarMenu, SidebarMenuButton, SidebarMenuItem, SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";

const options = [{ name: "Dashboard", icon: Grid2X2 }, { name: "Clientes", icon: CircleUserRound }, { name: "Produtos", icon: Package }];
const content = {
  Dashboard: { eyebrow: "VISÃO GERAL", title: "A casa da sua experiência.", text: "Um espaço pensado para reunir sabor, conversa e as melhores escolhas da Tabacaria Uai." },
  Clientes: { eyebrow: "CLIENTES", title: "Relacionamentos que deixam marca.", text: "Esta área será o ponto de partida para acompanhar e cuidar de cada cliente da Tabacaria Uai." },
  Produtos: { eyebrow: "PRODUTOS", title: "O seu catálogo, do seu jeito.", text: "Em breve, organize produtos, novidades e tudo que faz parte da nossa curadoria." },
};

export default function Home() {
  const [active, setActive] = useState<keyof typeof content>("Dashboard");
  const current = content[active];
  return <SidebarProvider defaultOpen>
    <Sidebar collapsible="offcanvas" className="border-r border-white/10 bg-[#15110e] text-[#f8f2e9]">
      <SidebarHeader className="p-7 pb-5"><img src="/logo-uai.jpg" alt="Uai Tabacaria e Adega" className="h-auto w-full rounded-sm bg-white p-2" /></SidebarHeader>
      <SidebarContent className="px-4"><SidebarGroup className="p-0"><SidebarGroupContent><SidebarMenu className="gap-2">
        {options.map((option) => { const Icon = option.icon; return <SidebarMenuItem key={option.name}><SidebarMenuButton isActive={active === option.name} tooltip={option.name} onClick={() => setActive(option.name as keyof typeof content)} className="h-12 rounded-xl px-4 text-[0.9rem] font-semibold text-[#d9cabe] hover:bg-[#34251d] hover:text-white data-[active=true]:bg-[#c88639] data-[active=true]:text-[#17110d]"><Icon className="size-[18px]" /><span>{option.name}</span></SidebarMenuButton></SidebarMenuItem>; })}
      </SidebarMenu></SidebarGroupContent></SidebarGroup></SidebarContent>
      <SidebarFooter className="p-6 text-xs leading-relaxed text-[#a79587]"><span className="block font-semibold tracking-[0.18em] text-[#d3b68f]">TABACARIA UAI</span><span className="mt-1 block">Tabacaria e Adega</span></SidebarFooter>
    </Sidebar>
    <SidebarInset className="min-h-svh bg-[#f3eee6]">
      <header className="flex items-center justify-between border-b border-[#d9cdc0] px-5 py-4 md:px-10"><div className="flex items-center gap-3"><SidebarTrigger className="text-[#5a4030] hover:bg-[#e7dbcf]" /><span className="hidden text-sm font-medium text-[#705c4d] sm:block">Tabacaria Uai</span></div><a href="https://www.instagram.com/uaitabacariaeadega/" target="_blank" rel="noreferrer" aria-label="Abrir Instagram da Tabacaria Uai"><Button variant="outline" className="border-[#b89a78] bg-transparent text-[#38251b] hover:bg-[#e7d6c3]"><Instagram className="size-4" /> Instagram</Button></a></header>
      <main className="relative flex min-h-[calc(100svh-73px)] items-center overflow-hidden px-6 py-12 md:px-14 lg:px-20">
        <div className="absolute -right-24 top-12 h-80 w-80 rounded-full bg-[#d79850]/25 blur-3xl" /><div className="absolute bottom-0 left-[20%] h-48 w-48 rounded-full bg-[#6e4532]/10 blur-3xl" />
        <section className="relative mx-auto grid w-full max-w-6xl items-center gap-12 lg:grid-cols-[1.15fr_.85fr]"><div><div className="mb-7 flex items-center gap-3 text-xs font-bold tracking-[0.2em] text-[#9a652d]"><span className="h-px w-10 bg-[#b67836]" /> {current.eyebrow}</div><h1 className="max-w-3xl font-serif text-5xl font-semibold leading-[0.98] tracking-tight text-[#241812] sm:text-6xl lg:text-7xl">{current.title}</h1><p className="mt-7 max-w-xl text-lg leading-8 text-[#69584c]">{current.text}</p><div className="mt-10 flex flex-wrap gap-3"><a href="https://www.instagram.com/uaitabacariaeadega/" target="_blank" rel="noreferrer"><Button className="h-12 rounded-xl bg-[#342016] px-5 text-[#fff8ee] hover:bg-[#5a3421]">Conheça no Instagram <Instagram className="size-4" /></Button></a><Button variant="outline" onClick={() => setActive("Produtos")} className="h-12 rounded-xl border-[#cdb49c] bg-transparent px-5 text-[#4c3325] hover:bg-[#e6d7c8]">Ver produtos <Box className="size-4" /></Button></div></div>
          <div className="relative mx-auto w-full max-w-md"><div className="rounded-[2rem] border border-[#d6c2ad] bg-[#fbf8f3]/85 p-4 shadow-[0_28px_70px_rgba(61,35,22,.15)] backdrop-blur-sm"><div className="overflow-hidden rounded-[1.4rem] bg-[#1d1510] p-8 text-center"><img src="/logo-uai.jpg" alt="Logo Tabacaria Uai" className="mx-auto w-full max-w-[270px] rounded-sm" /><div className="mt-8 border-t border-white/15 pt-6"><p className="text-xs font-semibold tracking-[0.24em] text-[#e1aa69]">TABACARIA & ADEGA</p><p className="mt-3 text-base leading-6 text-[#eadccf]">Curadoria, tradição e boas histórias para compartilhar.</p></div></div><div className="flex items-center justify-between px-3 pb-2 pt-5 text-sm text-[#6f5847]"><span>Em breve, mais novidades.</span><Sparkles className="size-4 text-[#b87836]" /></div></div></div>
        </section>
      </main>
    </SidebarInset>
  </SidebarProvider>;
}
