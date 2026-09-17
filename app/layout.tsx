import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Uai ERP | Tabacaria e Adega",
  description: "Sistema de gestão da Tabacaria Uai.",
  icons: { icon: "/favicon.svg", shortcut: "/favicon.svg" },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body className="antialiased">{children}</body></html>;
}
