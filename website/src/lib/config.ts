const repo = process.env.NEXT_PUBLIC_GITHUB_REPO || "anomalyco/VideoPlayerUI";

export const GITHUB_REPO = repo;
export const GITHUB_URL = `https://github.com/${repo}`;
export const GITHUB_RELEASES_URL = `${GITHUB_URL}/releases`;
export const GITHUB_LATEST_URL = `${GITHUB_RELEASES_URL}/latest`;
export const GITHUB_API_LATEST = `https://api.github.com/repos/${repo}/releases/latest`;
export const LICENSE_URL = `${GITHUB_URL}/blob/main/LICENSE`;
