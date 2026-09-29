// Renders the App Store panels (1284x2778, MODE style) from the raw simulator
// screenshots in ./raw. Run from mode-app so Playwright resolves:
//   node ../quitgambling-v2/appstore-screens/make-panels.js
const path = require('path');
const fs = require('fs');
const { chromium } = require(path.join(__dirname, '../../mode-app/node_modules/playwright'));

const W = 1284, H = 2778, ACCENT = '#F2B840';
const RAW = path.join(__dirname, 'raw');
const OUT = path.join(__dirname, 'panels');

const PANELS = {
  en: [
    { front: 'home', back: 'tracker', top: true, title: ['Every clean', 'day counts.'], sub: 'Watch your gamble-free streak and the money you keep grow day by day.' },
    { front: 'shield', back: 'home', top: false, title: ['Block betting', 'apps and sites.'], sub: 'Screen Time shield, Safari extension and an optional DNS filter.' },
    { front: 'sos', back: 'shield', top: true, title: ['Beat the urge', 'in minutes.'], sub: 'Breathing, urge surfing, brain games and helplines when it hits hard.' },
    { front: 'tracker', back: 'sos', top: false, title: ['See how far', 'you have come.'], sub: 'Calendar, milestones and your savings, all in one place.' },
  ],
  de: [
    { front: 'home', back: 'tracker', top: true, title: ['Jeder Tag ohne', 'Wetten zählt.'], sub: 'Sieh zu, wie deine spielfreien Tage und dein gespartes Geld wachsen.' },
    { front: 'shield', back: 'home', top: false, title: ['Wettseiten und', 'Apps sperren.'], sub: 'Bildschirmzeit-Schutz, Safari-Erweiterung und optionaler DNS-Filter.' },
    { front: 'sos', back: 'shield', top: true, title: ['Den Drang in', 'Minuten besiegen.'], sub: 'Atemübung, Urge Surfing, Denkspiele und Hilfetelefone, wenn es schwer wird.' },
    { front: 'tracker', back: 'sos', top: false, title: ['Dein Weg auf', 'einen Blick.'], sub: 'Kalender, Meilensteine und dein Erspartes an einem Ort.' },
  ],
};

const img = (lang, name) => 'data:image/png;base64,' + fs.readFileSync(path.join(RAW, `${lang}_${name}.png`)).toString('base64');

function phone(src, w, x, y, opacity) {
  const h = Math.round(w * 2778 / 1284);
  const bezel = Math.round(w * 0.028);
  const outerR = Math.round(w * 0.125), innerR = Math.round(w * 0.111);
  const isl = { w: Math.round(w * 0.252), h: Math.round(w * 0.072) };
  return `
  <div class="phone" style="left:${x}px;top:${y}px;width:${w + bezel * 2}px;height:${h + bezel * 2}px;border-radius:${outerR}px;opacity:${opacity}">
    <div class="screen" style="left:${bezel}px;top:${bezel}px;width:${w}px;height:${h}px;border-radius:${innerR}px;background-image:url(${src})"></div>
    <div class="island" style="left:${bezel + (w - isl.w) / 2}px;top:${bezel + Math.round(h * 28 / 926) - isl.h / 2}px;width:${isl.w}px;height:${isl.h}px"></div>
  </div>`;
}

function html(lang, p) {
  const glow = p.top ? 'left:400px;top:-420px' : 'left:-500px;top:1500px';
  const textY = p.top ? 250 : 1880;
  const phonesY = p.top ? 1000 : -380;
  return `<!doctype html><html><head><meta charset="utf-8">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=block" rel="stylesheet">
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    body{width:${W}px;height:${H}px;background:#0E0E10;overflow:hidden;position:relative;font-family:Inter,sans-serif}
    .glow{position:absolute;${glow};width:1500px;height:1100px;border-radius:50%;background:${ACCENT};opacity:.2;filter:blur(250px)}
    .text{position:absolute;left:110px;top:${textY}px;width:1064px;color:#fff}
    h1{font-weight:700;font-size:96px;line-height:104px;letter-spacing:-.035em}
    p{margin-top:28px;font-size:40px;line-height:54px;color:#B8B3B3;width:1004px}
    .stage{position:absolute;left:0;top:${phonesY}px;width:${W}px;height:2200px;transform:rotate(-13deg);transform-origin:50% 50%}
    .phone{position:absolute;background:linear-gradient(135deg,#9E9EA8,#29292E 35%,#6B6B75 65%,#17171A);box-shadow:0 60px 160px rgba(0,0,0,.75)}
    .screen{position:absolute;background-size:cover;background-position:top center}
    .island{position:absolute;background:#000;border-radius:999px;box-shadow:inset 0 0 0 2px rgba(255,255,255,.08)}
  </style></head><body>
    <div class="glow"></div>
    <div class="stage">
      ${phone(img(lang, p.back), 620, 700, p.top ? 40 : 520, 0.72)}
      ${phone(img(lang, p.front), 780, 170, p.top ? 180 : 380, 1)}
    </div>
    <div class="text"><h1>${p.title.join('<br>')}</h1><p>${p.sub}</p></div>
  </body></html>`;
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: W, height: H } });
  for (const [lang, list] of Object.entries(PANELS)) {
    for (let i = 0; i < list.length; i++) {
      await page.setContent(html(lang, list[i]), { waitUntil: 'networkidle' });
      await page.evaluate(() => document.fonts.ready);
      const file = path.join(OUT, `${lang}_${i + 1}.png`);
      await page.screenshot({ path: file });
      console.log(file);
    }
  }
  await browser.close();
})();
