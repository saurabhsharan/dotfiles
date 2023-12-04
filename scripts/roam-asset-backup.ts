// Usage: `bun run roam-asset-backup.ts`

import * as fs from "fs";
import axios from "axios";
import * as path from "path";

const JSON_FILE = "./saurabhs.json";
const OUTPUT_DIR = "downloaded_images";
const BASE_URL =
  "https://firebasestorage.googleapis.com/v0/b/firescript-577a2.appspot.com/o/imgs";

async function downloadImage(url: string, outputPath: string): Promise<void> {
  const response = await axios({
    method: "GET",
    url: url,
    responseType: "stream",
  });

  response.data.pipe(fs.createWriteStream(outputPath));
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
    fs.mkdirSync(OUTPUT_DIR);
  }

  const fileContent = fs.readFileSync(JSON_FILE, "utf8");
  const regex = new RegExp(`${BASE_URL}[^", ]+`, "g");
  const matches = fileContent.match(regex);

  if (matches) {
    for (const url of matches) {
      var normalizedUrl = cleanTrailingParen(url);
      const fileName = path.basename(normalizedUrl) + ".png";
      const filePath = path.join(OUTPUT_DIR, fileName);

      if (!fs.existsSync(filePath)) {
        console.log(`Downloading: ${normalizedUrl}`);
        await downloadImage(normalizedUrl, filePath);
      } else {
        console.log(`Skipping already downloaded file: ${fileName}`);
      }
    }
  }
}

main().catch(console.error);
