cask "rift" do
  version "1.0.0-dev.56"
  sha256 "2622ba982a22c5ce97465be212ce3926d8859d8e56e4a86b796caed941169455"

  url "https://github.com/rafaelo96/RiftVideoPlayer/releases/download/v#{version}/Rift.dmg"
  name "Rift"
  desc "Native video player with Frame⁺ AI interpolation, HDR support, and Metal-accelerated rendering"
  homepage "https://github.com/rafaelo96/RiftVideoPlayer"

  auto_updates false

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
