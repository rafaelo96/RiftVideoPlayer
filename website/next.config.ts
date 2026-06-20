import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  compress: true,
  images: {
    deviceSizes: [640, 1024, 2048],
    imageSizes: [32, 64, 128, 256]
  }
};

export default nextConfig;
