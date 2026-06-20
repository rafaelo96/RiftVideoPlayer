import Image from "next/image";

type RiftMarkProps = {
  compact?: boolean;
  priority?: boolean;
};

export default function RiftMark({ compact = false, priority = false }: RiftMarkProps) {
  return (
    <span className="rift-mark" aria-label="Rift">
      <Image
        className="rift-icon"
        src="/rift-icon.png"
        alt=""
        width={32}
        height={32}
        priority={priority}
        sizes="32px"
      />
      {!compact && <span>Rift</span>}
    </span>
  );
}
