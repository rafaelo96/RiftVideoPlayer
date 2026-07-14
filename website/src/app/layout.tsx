import type { Metadata } from "next";
import { Bricolage_Grotesque, Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import ClientLayout from "@/components/ClientLayout";

const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";
const githubUrl = `https://github.com/${process.env.NEXT_PUBLIC_GITHUB_REPO || "anomalyco/VideoPlayerUI"}`;

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
  icons: {
    icon: `${basePath}/icon.svg`,
  },
  manifest: `${basePath}/manifest.json`,
  other: {
    "theme-color": "#0f0f1a",
  },
  openGraph: {
    title: "Rift — Cinematic Video Player for macOS",
    description:
      "Frame-perfect video playback with AI motion interpolation and liquid glass UI.",
    url: "https://riftplayer.app",
    siteName: "Rift",
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Rift — Cinematic Video Player for macOS",
    description:
      "Frame-perfect video playback with AI motion interpolation and liquid glass UI.",
  },
};

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "Rift",
  applicationCategory: "MultimediaApplication",
  operatingSystem: "macOS 14+",
  description: "Cinematic video player for macOS with HDR playback, Metal rendering, and AI motion interpolation.",
  offers: {
    "@type": "Offer",
    price: "0",
    priceCurrency: "USD",
  },
  author: {
    "@type": "Organization",
    name: "Rift",
    url: githubUrl,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${body.variable} ${display.variable} ${mono.variable}`}>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className="font-sans bg-bg text-white antialiased">
        <ClientLayout>{children}</ClientLayout>
      </body>
    </html>
  );
}
