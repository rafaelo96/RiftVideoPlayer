"use client";

import { useEffect } from "react";

const domain = process.env.NEXT_PUBLIC_PLAUSIBLE_DOMAIN;

export default function Analytics() {
  useEffect(() => {
    if (!domain || window.location.hostname === "localhost") return;

    const script = document.createElement("script");
    script.src = "https://plausible.io/js/script.js";
    script.defer = true;
    script.setAttribute("data-domain", domain);
    document.head.appendChild(script);
  }, []);

  return null;
}
