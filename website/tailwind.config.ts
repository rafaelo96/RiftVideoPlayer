import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-inter)", "Inter", "-apple-system", "BlinkMacSystemFont", "SF Pro Display", "system-ui", "sans-serif"],
        display: ["var(--font-display)", "SF Pro Display", "Inter", "-apple-system", "BlinkMacSystemFont", "system-ui", "sans-serif"]
      },
      colors: {
        ink: {
          950: "oklch(0.105 0.012 255)",
          900: "oklch(0.145 0.015 255)",
          800: "oklch(0.19 0.019 255)"
        },
        frost: {
          100: "oklch(0.965 0.008 255)",
          200: "oklch(0.88 0.014 255)",
          500: "oklch(0.66 0.03 255)"
        },
        electric: {
          300: "oklch(0.79 0.12 252)",
          400: "oklch(0.69 0.16 252)",
          500: "oklch(0.61 0.18 252)"
        }
      },
      boxShadow: {
        glow: "0 0 60px color-mix(in oklab, var(--electric) 30%, transparent)",
        lift: "0 30px 90px rgba(0, 0, 0, 0.42)"
      },
      transitionTimingFunction: {
        out: "cubic-bezier(0.16, 1, 0.3, 1)",
        expo: "cubic-bezier(0.19, 1, 0.22, 1)"
      }
    }
  },
  plugins: []
};

export default config;
