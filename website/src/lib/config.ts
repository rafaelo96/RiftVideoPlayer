const repo = process.env.NEXT_PUBLIC_GITHUB_REPO || "anomalyco/VideoPlayerUI";
const downloadRepo = process.env.NEXT_PUBLIC_DOWNLOAD_REPO || repo;
const downloadAssetName = process.env.NEXT_PUBLIC_DOWNLOAD_ASSET_NAME || "Rift.dmg";

export const GITHUB_REPO = repo;
export const GITHUB_URL = `https://github.com/${repo}`;
export const GITHUB_RELEASES_URL = `${GITHUB_URL}/releases`;

const directDownloadUrl = process.env.NEXT_PUBLIC_DOWNLOAD_URL;
export const GITHUB_LATEST_URL = directDownloadUrl || `https://github.com/${downloadRepo}/releases/latest/download/${downloadAssetName}`;
export const GITHUB_API_LATEST = `https://api.github.com/repos/${downloadRepo}/releases/latest`;
export const LICENSE_URL = `${GITHUB_URL}/blob/main/LICENSE`;
