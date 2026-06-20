import { Github } from "lucide-react";
import RiftMark from "./RiftMark";

export default function Footer() {
  return (
    <footer className="site-footer section-pad">
      <div className="content-grid footer-inner">
        <div className="footer-brand">
          <RiftMark compact />
          <span className="footer-tagline">Reproductor de video premium para macOS</span>
        </div>
        <div className="footer-links">
          <a href="https://github.com/rafaelo96/RiftVideoPlayer" target="_blank" rel="noreferrer">
            <Github size={15} />
            GitHub
          </a>
          <a href="#top">Contacto</a>
          <a href="#top">Privacidad</a>
          <a href="#top">Términos</a>
        </div>
        <small className="footer-copy">
          &copy; {new Date().getFullYear()} Rift. Hecho con Swift, Metal y obsesión.
        </small>
      </div>
    </footer>
  );
}
