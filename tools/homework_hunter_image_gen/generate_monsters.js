#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 宿題ハンター ボスモンスター画像 一括生成（Leonardo.ai版）
// 4体固定のため leonardo-ai-image-gen スキルのカード用テンプレートは使わず、
// このアプリ専用の簡易スクリプトとして実装（原本: card_crown/tools/seed_card_image_gen）
//
// 使い方（PowerShell）:
//   $env:LEONARDO_API_KEY = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY","User")
//   node generate_monsters.js --all
//   node generate_monsters.js --ids kanji_goblin
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3';
const OUTPUT_DIR = path.join(__dirname, 'output');
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

const NEGATIVE_PROMPT =
  'text, logo, watermark, signature, stamp, seal, border, frame, scary, gore, blood, ' +
  'realistic human, photorealistic, low quality, blurry, extra limbs, deformed';

const STYLE_SUFFIX =
  'flat vector cartoon illustration, thick clean outlines, soft rounded shapes, ' +
  'bright vivid pop colors, friendly and huggable not scary, simple solid pastel ' +
  'background, single character centered, elementary school kids game mascot style';

const MONSTERS = [
  {
    id: 'kanji_goblin',
    nameJp: '漢字ゴブリン',
    prompt:
      'A single cute mischievous monster character: "Kanji Goblin", made of folded washi paper and ink, ' +
      'small round chubby body, big sparkling round eyes, tiny horns, holding a giant pencil like a staff, ' +
      'warm orange and cream color palette, ' + STYLE_SUFFIX,
  },
  {
    id: 'kuku_slime',
    nameJp: '九九スライム',
    prompt:
      'A single cute bouncy monster character: "Kuku Slime", a round jelly slime with tiny floating ' +
      'multiplication number symbols glowing softly inside its translucent body, small stubby arms, ' +
      'big cute eyes, glossy shine highlight, vivid red color palette, ' + STYLE_SUFFIX,
  },
  {
    id: 'prefecture_dragon',
    nameJp: '都道府県ドラゴン',
    prompt:
      'A single cute chibi baby dragon character: "Prefecture Dragon", small round body with tiny wings, ' +
      'wearing a scarf patterned like a simple Japan map, big friendly eyes, small blunt horns, ' +
      'vivid green color palette, ' + STYLE_SUFFIX,
  },
  {
    id: 'experiment_ghost',
    nameJp: '実験オバケ',
    prompt:
      'A single cute round floating ghost character: "Experiment Ghost", soft wavy bottom edge, ' +
      'holding a bubbling science flask with colorful liquid, tiny goggles pushed up on its head, ' +
      'big round eyes, semi-transparent glow, vivid sky blue color palette, ' + STYLE_SUFFIX,
  },
];

async function generateImage(prompt) {
  const createRes = await fetch(`${API_BASE}/generations`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${LEONARDO_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      negative_prompt: NEGATIVE_PROMPT,
      modelId: LEONARDO_MODEL_ID,
      width: 512,
      height: 512,
      num_images: 1,
      alchemy: false,
      photoReal: false,
    }),
  });

  if (!createRes.ok) {
    throw new Error(`Leonardo API error (create): ${createRes.status} ${await createRes.text()}`);
  }

  const created = await createRes.json();
  const genId = created?.sdGenerationJob?.generationId;
  if (!genId) {
    throw new Error(`generationId が取得できませんでした: ${JSON.stringify(created)}`);
  }

  let attempts = 0;
  let images = null;
  while (attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`${API_BASE}/generations/${genId}`, {
      headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
    });
    if (!poll.ok) {
      throw new Error(`Leonardo API error (poll): ${poll.status} ${await poll.text()}`);
    }
    const data = await poll.json();
    const gen = data.generations_by_pk;
    if (gen?.status === 'COMPLETE') {
      images = gen.generated_images;
      break;
    }
    if (gen?.status === 'FAILED') {
      throw new Error(`generation failed: ${JSON.stringify(gen)}`);
    }
    attempts++;
  }

  if (!images || !images[0]?.url) {
    throw new Error('画像生成がタイムアウトしました');
  }

  return images[0].url;
}

async function downloadTo(url, filePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(filePath, buf);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { ids: null, all: false, force: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--ids') opts.ids = args[++i].split(',').map((s) => s.trim());
    else if (args[i] === '--all') opts.all = true;
    else if (args[i] === '--force') opts.force = true;
  }
  return opts;
}

async function main() {
  if (!LEONARDO_API_KEY) {
    console.error('❌ LEONARDO_API_KEY が設定されていません。');
    process.exit(1);
  }

  const opts = parseArgs();
  const target = opts.ids ? MONSTERS.filter((m) => opts.ids.includes(m.id)) : MONSTERS;

  if (target.length === 0) {
    console.error('❌ 対象モンスターが見つかりません（--ids または --all を指定）');
    process.exit(1);
  }

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const manifestPath = path.join(OUTPUT_DIR, 'manifest.json');
  const manifest = fs.existsSync(manifestPath)
    ? JSON.parse(fs.readFileSync(manifestPath, 'utf8'))
    : {};

  let skipped = 0;
  const toGenerate = opts.force
    ? target
    : target.filter((m) => {
        const exists = fs.existsSync(path.join(OUTPUT_DIR, `${m.id}.png`));
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) {
    console.log(`⏭️  既存の${skipped}枚をスキップ（再生成するには --force）`);
  }
  console.log(`🎨 ${toGenerate.length}枚を生成します（Leonardo Phoenix / 512x512 / alchemy=off）\n`);

  for (const m of toGenerate) {
    process.stdout.write(`  ${m.id} (${m.nameJp}) ... `);
    try {
      const imageUrl = await generateImage(m.prompt);
      const outFile = path.join(OUTPUT_DIR, `${m.id}.png`);
      await downloadTo(imageUrl, outFile);
      manifest[m.id] = {
        nameJp: m.nameJp,
        file: `${m.id}.png`,
        prompt: m.prompt,
        provider: 'leonardo',
        modelId: LEONARDO_MODEL_ID,
        generatedAt: new Date().toISOString(),
      };
      fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
      console.log('✅');
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n完了（生成${toGenerate.length}枚 / スキップ${skipped}枚）。出力先: ${OUTPUT_DIR}`);
}

main().catch((e) => {
  console.error(`❌ 予期しないエラー: ${e.message}`);
  process.exit(1);
});
