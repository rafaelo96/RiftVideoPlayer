cask "rift" do
  version "1.0.0-dev.49-3-g1bae421"
  sha256 "d8f7d9377e52360a0c4037f45218c17e42ff5292975f71d8e6a0bdf20f34d952"

  url "https://github.com/rafaelo96/RiftVideoPlayer/releases/download/v#{version}/Rift.dmg"
  name "Rift"
  desc "Native video player with Frame⁺ AI interpolation, HDR support, and Metal-accelerated rendering"
  homepage "https://github.com/rafaelo96/RiftVideoPlayer"

  auto_updates false
  quarantine false

  app "Rift.app"

  postflight do
    system_command "xattr",
                   args: ["-cr", "#{appdir}/Rift.app"]
  end

  zap trash: [
    "~/Library/Application Support/Rift",
    "~/Library/Caches/Rift",
    "~/Library/Preferences/com.rift.player.plist",
  ]
end
