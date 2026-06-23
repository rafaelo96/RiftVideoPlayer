import type { Metadata } from "next";
import { Bricolage_Grotesque, Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import ClientLayout from "@/components/ClientLayout";

const body = Geist({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-body-family",
});

const display = Bricolage_Grotesque({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-display-family",
});

const mono = Geist_Mono({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-mono-family",
});

export const metadata: Metadata = {
  title: "Rift — Cinematic Video Player for macOS",
  description:
    "Rift transforms your Mac into a high-end cinema display. Frame-perfect video, real-time AI motion interpolation, and a liquid glass interface.",
  openGraph: {
    title: "Rift — Cinematic Video Player for macOS",
    description:
      "Frame-perfect video playback with AI motion interpolation and liquid glass UI.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${body.variable} ${display.variable} ${mono.variable}`}>
      <body className="font-sans bg-bg text-white antialiased">
        <ClientLayout>{children}</ClientLayout>
      </body>
    </html>
  );
}
