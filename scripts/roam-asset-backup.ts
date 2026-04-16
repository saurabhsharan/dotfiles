// Usage: `bun run roam-asset-backup.ts`

import * as fs from "fs";
import axios from "axios";
import * as path from "path";
import { pipeline } from "stream/promises";

const JSON_FILE = "./saurabhs.json";
const OUTPUT_DIR = "downloaded_images";
const BASE_URL =
  "https://firebasestorage.googleapis.com/v0/b/firescript-577a2.appspot.com/o/imgs";

// Treat BASE_URL literally when embedding it in a larger regex.
const escapeRegex = (value: string) =>
  value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

const unlinkIfExists = async (filePath: string) => {
  try {
    await fs.promises.unlink(filePath);
  } catch (error) {
    if ((error as { code?: string }).code !== "ENOENT") {
      throw error;
    }
  }
};

async function downloadImage(url: string, outputPath: string): Promise<void> {
  // Write beside the destination, then rename so interrupted downloads are not trusted later.
  const tempPath = `${outputPath}.download`;

  try {
    await unlinkIfExists(tempPath);
    const response = await axios({
      method: "GET",
      url: url,
      responseType: "stream",
    });

    await pipeline(response.data, fs.createWriteStream(tempPath));
    await fs.promises.rename(tempPath, outputPath);
  } catch (error) {
    await unlinkIfExists(tempPath);
    throw error;
  }
}

// Fix regex (and roam) bug where the `)` is part of the URL
const cleanTrailingParen = (url: string) => {
  const idx = url.indexOf(")");
  if (idx !== -1) {
    return url.substring(0, idx);
  }
  return url;
};

async function main() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const fileContent = fs.readFileSync(JSON_FILE, "utf8");
  const regex = new RegExp(`${escapeRegex(BASE_URL)}[^\\s"',)\\]}\\\\]+`, "g");
  const matches = fileContent.match(regex);

  let skipped = 0;
  let downloaded = 0;
  let failed = 0;
  let duplicateMatches = 0;
  const seenFilePaths = new Set<string>();

  if (matches) {
    for (const url of matches) {
      const normalizedUrl = cleanTrailingParen(url);
      const fileName = path.basename(normalizedUrl) + ".png";
      const filePath = path.join(OUTPUT_DIR, fileName);

      if (seenFilePaths.has(filePath)) {
        duplicateMatches++;
        continue;
      }
      seenFilePaths.add(filePath);

      if (!fs.existsSync(filePath)) {
        console.log(`Downloading: ${normalizedUrl}`);
        try {
          await downloadImage(normalizedUrl, filePath);
          downloaded++;
        } catch (error) {
          // Keep going so one bad URL does not hide later missing assets.
          failed++;
          const message = error instanceof Error ? error.message : String(error);
          console.error(`Failed to download ${normalizedUrl}: ${message}`);
        }
      } else {
        skipped++;
        console.log(`Skipping already downloaded file: ${fileName}`);
      }
    }
  }

  console.log(
    `Done. downloaded=${downloaded} skipped=${skipped} failed=${failed} duplicateMatches=${duplicateMatches}`,
  );

  if (failed > 0) {
    process.exitCode = 1;
  }
}

main().catch(console.error);
