import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import dynamic from "next/dynamic";
import "./globals.css";

const Analytics = dynamic(() => import("@/components/Analytics"));

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap"
});

export const metadata: Metadata = {
  metadataBase: new URL("https://riftplayer.app"),
  title: {
    default: "Rift, reproductor de video premium para macOS",
    template: "%s | Rift"
  },
  description:
    "Rift es un reproductor de video moderno para macOS, diseñado para abrir rápido, reproducir fluido y sentirse nativo.",
  keywords: [
    "Rift",
    "macOS video player",
    "Apple Silicon",
    "SwiftUI",
    "AVFoundation",
    "Metal",
    "video player"
  ],
  authors: [{ name: "Rafael" }],
  creator: "Rafael",
  openGraph: {
    title: "Rift, video en macOS con velocidad y calma",
    description:
      "Un reproductor de video moderno, fluido y cuidadosamente diseñado para Mac.",
    url: "https://riftplayer.app",
    siteName: "Rift",
    images: [
      {
        url: "/rift-icon-256.png",
        width: 256,
        height: 256,
        alt: "Icono de Rift"
      }
    ],
    locale: "es_MX",
    type: "website"
  },
  twitter: {
    card: "summary_large_image",
    title: "Rift, reproductor premium para macOS",
    description: "Video rápido, fluido y nativo para Mac.",
    images: ["/rift-icon-256.png"]
  },
  icons: {
    icon: "/rift-icon-256.png",
    apple: "/rift-icon-256.png",
    shortcut: "/rift-icon-64.png"
  }
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
  themeColor: "#080a10"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es" className={inter.variable}>
      <body>
        <a href="#main-content" className="skip-link">
          Saltar al contenido principal
        </a>
        <Analytics />
        {children}
      </body>
    </html>
  );
}
