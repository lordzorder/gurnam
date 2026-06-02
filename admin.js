const ADMIN_STORAGE_KEY = 'gurnamAdminContent';
const LEGACY_STORAGE_KEY = 'gurnamSiteContent';

const FONT_OPTIONS = [
  'Arial',
  'Helvetica',
  'Times New Roman',
  'Georgia',
  'Verdana',
  'Trebuchet MS',
  'Courier New',
  'Inter',
  'Roboto',
  'Open Sans',
  'Lato',
  'Montserrat'
];

const TYPE_LABELS = {
  'home-section': 'Főoldali szekció',
  'system-page': 'Aloldal',
  'blog-post': 'Blogbejegyzés'
};

const STATUS_LABELS = {
  published: 'Publikált',
  draft: 'Vázlat'
};

const EXISTING_IMAGES = [
  { id: 'existing-hero-bg', fileName: 'hero-bg.jpg', folder: 'images', path: 'images/hero-bg.jpg', src: 'images/hero-bg.jpg' },
  { id: 'existing-hero', fileName: 'hero.jpg', folder: 'images', path: 'images/hero.jpg', src: 'images/hero.jpg' },
  { id: 'existing-mantra', fileName: 'mantra.jpg', folder: 'images', path: 'images/mantra.jpg', src: 'images/mantra.jpg' },
  { id: 'existing-meditation', fileName: 'meditation.jpg', folder: 'images', path: 'images/meditation.jpg', src: 'images/meditation.jpg' },
  { id: 'existing-kriya', fileName: 'kriya.jpg', folder: 'images', path: 'images/kriya.jpg', src: 'images/kriya.jpg' }
];

let state = null;
let currentItemId = null;
let savedRange = null;

document.addEventListener('DOMContentLoaded', () => {
  state = loadState();
  populateFontControls();
  populateImageSelects();
  bindNavigation();
  bindDashboardActions();
  bindEditor();
  bindRichTextEditor();
  bindUploader();
  renderContentList();
  renderImageLibrary();
  selectFirstEditableItem();
});

function nowIso() {
  return new Date().toISOString();
}

function formatDate(value) {
  if (!value) return '-';
  try {
    return new Intl.DateTimeFormat('hu-HU', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).format(new Date(value));
  } catch {
    return value;
  }
}

function safeId(prefix = 'item') {
  return `${prefix}-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function slugify(value) {
  return String(value || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '') || 'uj-tartalom';
}

function loadState() {
  const saved = safeJson(localStorage.getItem(ADMIN_STORAGE_KEY));
  const base = saved || createDefaultState();
  base.items = mergeCoreItems(base.items || []);
  base.images = Array.isArray(base.images) ? base.images : [];
  return base;
}

function safeJson(value) {
  if (!value) return null;
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}

function createDefaultState() {
  const legacy = {
    ...(typeof DEFAULT_CONTENT !== 'undefined' ? DEFAULT_CONTENT : {}),
    ...(safeJson(localStorage.getItem(LEGACY_STORAGE_KEY)) || {})
  };

  return {
    version: 1,
    images: [],
    items: [
      {
        id: 'home-hero',
        type: 'home-section',
        locked: true,
        title: 'Főoldal - Hero',
        slug: 'index.html#hero',
        heroTitle: legacy.heroTitle || '',
        intro: legacy.heroSubtitle || '',
        contentHeading: '',
        bodyHtml: `<p>${legacy.heroButtonText || 'Részletek'}</p>`,
        ctaText: legacy.heroButtonText || 'Részletek',
        status: 'published',
        seoTitle: 'Gurnam Kundalini Jóga',
        seoDescription: '',
        lastModified: nowIso()
      },
      {
        id: 'home-teachings',
        type: 'home-section',
        locked: true,
        title: 'A Rendszer',
        slug: 'index.html#tanitasok',
        heroTitle: legacy.teachingsTitle || 'A Rendszer',
        intro: legacy.teachingsSubtitle || '',
        contentHeading: legacy.teachingsTitle || 'A Rendszer',
        bodyHtml: `<p>${legacy.teachingsSubtitle || ''}</p>`,
        status: 'published',
        seoTitle: '',
        seoDescription: '',
        lastModified: nowIso()
      },
      makeSystemPage({
        id: 'system-kundalini',
        title: legacy.kundaliniTitle || 'Kundalini Jóga',
        slug: 'kundalini-joga.html',
        heroImage: 'images/hero-bg.jpg',
        intro: 'Tudatos gyakorlás, amely a testet, a légzést, a figyelmet és a belső energiát egy irányba rendezi.',
        contentHeading: 'A gyakorlás lényege',
        cardSummary: legacy.kundaliniText || 'Dinamikus mozgás és légzés a kreatív életenergia felébresztésére és áramoltatására a testben.',
        bodyHtml: '<p>A Kundalini jóga gyakorlása nem csupán mozgás vagy légzéstechnika, hanem egy tudatos belső folyamat. Segít abban, hogy az ember kapcsolatba kerüljön saját energiájával, figyelmével és belső erejével. A gyakorlás során a test, az idegrendszer és az elme fokozatosan finomabb hangolásba kerül.</p>'
      }),
      makeSystemPage({
        id: 'system-mantra',
        title: legacy.mantraTitle || 'Mantra',
        slug: 'mantra.html',
        heroImage: 'images/mantra.jpg',
        intro: 'A hang és az ismétlés finom eszköze, amely a figyelmet lassan mélyebb csendbe vezeti.',
        contentHeading: 'A hang belső tere',
        cardSummary: legacy.mantraText || 'Szent hangrezgések használata az elme lecsendesítésére és az idegrendszer finomhangolására.',
        bodyHtml: '<p>A mantra ismétlése a figyelem irányításának egyik ősi eszköze. A hang rezgése nemcsak a gondolatokra hat, hanem az egész belső állapotra. A gyakorlás segíthet abban, hogy az elme lelassuljon, tisztuljon, és mélyebb csend jelenjen meg.</p>'
      }),
      makeSystemPage({
        id: 'system-meditacio',
        title: legacy.meditacioTitle || 'Meditáció',
        slug: 'meditacio.html',
        heroImage: 'images/meditation.jpg',
        intro: 'Visszatérés a jelenlétbe, ahol a figyelem tisztábban látja a testet, az elmét és a belső mozgásokat.',
        contentHeading: 'A jelenlét gyakorlása',
        cardSummary: legacy.meditacioText || 'A jelenlét mély megtapasztalása, a belső figyelem fókuszálása és az elme megtisztítása.',
        bodyHtml: '<p>A meditáció a jelenlét gyakorlása. Nem menekülés a világból, hanem visszatérés ahhoz a ponthoz, ahol az ember tisztábban érzékeli önmagát. A rendszeres gyakorlás segíthet a belső stabilitás, figyelem és nyugalom kialakításában.</p>'
      }),
      makeSystemPage({
        id: 'system-kriya',
        title: legacy.kriyaTitle || 'Kriya',
        slug: 'kriya.html',
        heroImage: 'images/kriya.jpg',
        intro: 'Felépített gyakorlatsor, amely konkrét testi, mentális vagy energetikai irányba vezeti a figyelmet.',
        contentHeading: 'Tudatos belső munka',
        cardSummary: legacy.kriyaText || 'Célzott gyakorlatsorok, amelyek specifikus fizikai, érzelmi vagy mentális hatást érnek el.',
        bodyHtml: '<p>A kriya célzott gyakorlatsor, amely meghatározott testi, mentális vagy energetikai hatás felé vezet. Nem véletlenszerű mozdulatok egymásutánja, hanem tudatosan felépített belső munka. A kriya segíthet átrendezni a figyelmet, az energiát és a belső működésmintákat.</p>'
      }),
      makeSystemPage({
        id: 'system-japji',
        title: legacy.japjiTitle || 'Japji Sahib',
        slug: 'japji-sahib.html',
        heroImage: 'images/hero-bg.jpg',
        intro: 'Hajnali meditatív szöveg, amely költői formában nyit teret az alázatnak, figyelemnek és belső iránynak.',
        contentHeading: 'A hajnali figyelem szövege',
        cardSummary: legacy.japjiText || 'A lélek éneke, hajnali spirituális fegyelem és mély meditációs szöveg a belső harmóniáért.',
        bodyHtml: '<p>A Japji Sahib a hajnali gyakorlás egyik fontos szövege a szikh és kundalini hagyományban. Költői és meditatív formában beszél az ember és a végtelen kapcsolatáról. Olvasása vagy recitálása segíthet a belső irány, alázat és tisztább tudatosság kialakításában.</p>'
      }),
      ...(legacy.blogs || []).map((blog, index) => makeBlogPost(blog, index))
    ]
  };
}

function makeSystemPage(overrides) {
  return {
    type: 'system-page',
    status: 'published',
    heroTitle: overrides.title,
    seoTitle: `${overrides.title} - Gurnam`,
    seoDescription: overrides.intro,
    lastModified: nowIso(),
    ...overrides
  };
}

function makeBlogPost(blog = {}, index = 0) {
  const title = blog.title || 'Új blogbejegyzés';
  return {
    id: blog.id ? `blog-${blog.id}` : safeId('blog'),
    type: 'blog-post',
    title,
    slug: `${slugify(title)}.html`,
    status: 'published',
    category: blog.category || '',
    heroTitle: title,
    heroImage: 'images/meditation.jpg',
    intro: blog.description || '',
    contentHeading: title,
    bodyHtml: `<p>${blog.description || ''}</p>`,
    buttonText: blog.buttonText || 'Tovább olvasom',
    seoTitle: title,
    seoDescription: blog.description || '',
    lastModified: nowIso(),
    sort: index
  };
}

function mergeCoreItems(items) {
  const defaultItems = createDefaultStateWithoutMerge().items;
  const merged = [...items];
  defaultItems
    .filter((item) => item.type === 'system-page' || item.type === 'home-section')
    .forEach((core) => {
      if (!merged.some((item) => item.id === core.id)) {
        merged.push(core);
      }
    });
  return merged;
}

function createDefaultStateWithoutMerge() {
  const legacy = {
    ...(typeof DEFAULT_CONTENT !== 'undefined' ? DEFAULT_CONTENT : {}),
    ...(safeJson(localStorage.getItem(LEGACY_STORAGE_KEY)) || {})
  };
  const previous = localStorage.getItem(ADMIN_STORAGE_KEY);
  localStorage.removeItem(ADMIN_STORAGE_KEY);
  const fresh = createDefaultStateRaw(legacy);
  if (previous) localStorage.setItem(ADMIN_STORAGE_KEY, previous);
  return fresh;
}

function createDefaultStateRaw(legacy) {
  return {
    version: 1,
    images: [],
    items: [
      {
        id: 'home-hero',
        type: 'home-section',
        locked: true,
        title: 'Főoldal - Hero',
        slug: 'index.html#hero',
        heroTitle: legacy.heroTitle || '',
        intro: legacy.heroSubtitle || '',
        contentHeading: '',
        bodyHtml: `<p>${legacy.heroButtonText || 'Részletek'}</p>`,
        ctaText: legacy.heroButtonText || 'Részletek',
        status: 'published',
        seoTitle: 'Gurnam Kundalini Jóga',
        seoDescription: '',
        lastModified: nowIso()
      },
      {
        id: 'home-teachings',
        type: 'home-section',
        locked: true,
        title: 'A Rendszer',
        slug: 'index.html#tanitasok',
        heroTitle: legacy.teachingsTitle || 'A Rendszer',
        intro: legacy.teachingsSubtitle || '',
        contentHeading: legacy.teachingsTitle || 'A Rendszer',
        bodyHtml: `<p>${legacy.teachingsSubtitle || ''}</p>`,
        status: 'published',
        seoTitle: '',
        seoDescription: '',
        lastModified: nowIso()
      },
      makeSystemPage({ id: 'system-kundalini', title: legacy.kundaliniTitle || 'Kundalini Jóga', slug: 'kundalini-joga.html', heroImage: 'images/hero-bg.jpg', intro: 'Tudatos gyakorlás, amely a testet, a légzést, a figyelmet és a belső energiát egy irányba rendezi.', contentHeading: 'A gyakorlás lényege', cardSummary: legacy.kundaliniText || '', bodyHtml: '<p>A Kundalini jóga gyakorlása nem csupán mozgás vagy légzéstechnika, hanem egy tudatos belső folyamat. Segít abban, hogy az ember kapcsolatba kerüljön saját energiájával, figyelmével és belső erejével. A gyakorlás során a test, az idegrendszer és az elme fokozatosan finomabb hangolásba kerül.</p>' }),
      makeSystemPage({ id: 'system-mantra', title: legacy.mantraTitle || 'Mantra', slug: 'mantra.html', heroImage: 'images/mantra.jpg', intro: 'A hang és az ismétlés finom eszköze, amely a figyelmet lassan mélyebb csendbe vezeti.', contentHeading: 'A hang belső tere', cardSummary: legacy.mantraText || '', bodyHtml: '<p>A mantra ismétlése a figyelem irányításának egyik ősi eszköze. A hang rezgése nemcsak a gondolatokra hat, hanem az egész belső állapotra. A gyakorlás segíthet abban, hogy az elme lelassuljon, tisztuljon, és mélyebb csend jelenjen meg.</p>' }),
      makeSystemPage({ id: 'system-meditacio', title: legacy.meditacioTitle || 'Meditáció', slug: 'meditacio.html', heroImage: 'images/meditation.jpg', intro: 'Visszatérés a jelenlétbe, ahol a figyelem tisztábban látja a testet, az elmét és a belső mozgásokat.', contentHeading: 'A jelenlét gyakorlása', cardSummary: legacy.meditacioText || '', bodyHtml: '<p>A meditáció a jelenlét gyakorlása. Nem menekülés a világból, hanem visszatérés ahhoz a ponthoz, ahol az ember tisztábban érzékeli önmagát. A rendszeres gyakorlás segíthet a belső stabilitás, figyelem és nyugalom kialakításában.</p>' }),
      makeSystemPage({ id: 'system-kriya', title: legacy.kriyaTitle || 'Kriya', slug: 'kriya.html', heroImage: 'images/kriya.jpg', intro: 'Felépített gyakorlatsor, amely konkrét testi, mentális vagy energetikai irányba vezeti a figyelmet.', contentHeading: 'Tudatos belső munka', cardSummary: legacy.kriyaText || '', bodyHtml: '<p>A kriya célzott gyakorlatsor, amely meghatározott testi, mentális vagy energetikai hatás felé vezet. Nem véletlenszerű mozdulatok egymásutánja, hanem tudatosan felépített belső munka. A kriya segíthet átrendezni a figyelmet, az energiát és a belső működésmintákat.</p>' }),
      makeSystemPage({ id: 'system-japji', title: legacy.japjiTitle || 'Japji Sahib', slug: 'japji-sahib.html', heroImage: 'images/hero-bg.jpg', intro: 'Hajnali meditatív szöveg, amely költői formában nyit teret az alázatnak, figyelemnek és belső iránynak.', contentHeading: 'A hajnali figyelem szövege', cardSummary: legacy.japjiText || '', bodyHtml: '<p>A Japji Sahib a hajnali gyakorlás egyik fontos szövege a szikh és kundalini hagyományban. Költői és meditatív formában beszél az ember és a végtelen kapcsolatáról. Olvasása vagy recitálása segíthet a belső irány, alázat és tisztább tudatosság kialakításában.</p>' })
    ]
  };
}

function bindNavigation() {
  document.querySelectorAll('.nav-item').forEach((button) => {
    button.addEventListener('click', () => showView(button.dataset.view));
  });
}

function showView(viewName) {
  document.querySelectorAll('.nav-item').forEach((button) => {
    button.classList.toggle('active', button.dataset.view === viewName);
  });
  document.querySelectorAll('.view').forEach((view) => {
    view.classList.toggle('active', view.id === viewName);
  });
  document.getElementById('view-title').textContent = viewName === 'media'
    ? 'Képek feltöltése'
    : viewName === 'editor'
      ? 'Szerkesztő'
      : 'Bejegyzések / Tartalmak';
}

function bindDashboardActions() {
  document.getElementById('add-page-btn').addEventListener('click', () => {
    const item = makeSystemPage({
      id: safeId('system'),
      title: 'Új aloldal',
      slug: 'uj-aloldal.html',
      heroImage: 'images/hero-bg.jpg',
      intro: '',
      contentHeading: 'Új aloldal',
      cardSummary: '',
      bodyHtml: '<p>Új tartalom.</p>',
      status: 'draft'
    });
    item.locked = false;
    state.items.push(item);
    editItem(item.id);
  });

  document.getElementById('add-blog-btn').addEventListener('click', () => {
    const item = makeBlogPost({ title: 'Új blogbejegyzés', description: '', category: 'Blog' });
    item.status = 'draft';
    state.items.push(item);
    editItem(item.id);
  });

  document.getElementById('global-save-btn').addEventListener('click', () => saveAll());
  document.getElementById('reset-btn').addEventListener('click', resetAll);
}

function bindEditor() {
  const form = document.getElementById('content-form');
  form.addEventListener('submit', (event) => {
    event.preventDefault();
    saveCurrentItem();
    saveAll();
  });

  document.getElementById('cancel-edit-btn').addEventListener('click', () => showView('dashboard'));
  document.getElementById('item-hero-image').addEventListener('change', updateHeroPreview);
  ['item-title', 'item-type', 'item-status', 'item-slug', 'item-hero-title', 'item-content-heading', 'item-intro'].forEach((id) => {
    document.getElementById(id).addEventListener('input', updatePreview);
  });

  document.getElementById('insert-image-btn').addEventListener('click', insertSelectedImageIntoEditor);
}

function bindRichTextEditor() {
  const editor = document.getElementById('item-body');
  const toolbar = document.querySelector('.rte-toolbar');
  document.execCommand('styleWithCSS', false, true);

  editor.addEventListener('keyup', saveSelection);
  editor.addEventListener('mouseup', saveSelection);
  editor.addEventListener('input', updatePreview);

  toolbar.addEventListener('mousedown', (event) => {
    if (event.target.closest('button') || event.target.closest('select')) {
      event.preventDefault();
    }
  });

  toolbar.querySelectorAll('[data-cmd]').forEach((button) => {
    button.addEventListener('click', () => runCommand(button.dataset.cmd));
  });

  document.getElementById('format-block').addEventListener('change', (event) => {
    runCommand('formatBlock', event.target.value);
    event.target.value = 'P';
  });

  document.getElementById('font-family').addEventListener('change', applyFontControls);
  document.getElementById('font-style').addEventListener('change', applyFontControls);

  toolbar.querySelector('[data-action="link"]').addEventListener('click', () => {
    restoreSelection();
    const url = prompt('Add meg a linket:', 'https://');
    if (!url) return;
    document.execCommand('createLink', false, url);
    editor.focus();
    saveSelection();
  });
}

function populateFontControls() {
  const select = document.getElementById('font-family');
  select.innerHTML = '<option value="">Betűtípus</option>' + FONT_OPTIONS
    .map((font) => `<option value="${escapeAttr(font)}">${font}</option>`)
    .join('');
}

function saveSelection() {
  const editor = document.getElementById('item-body');
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0) return;
  const range = selection.getRangeAt(0);
  if (editor.contains(range.commonAncestorContainer)) {
    savedRange = range.cloneRange();
  }
}

function restoreSelection() {
  const editor = document.getElementById('item-body');
  editor.focus();
  if (!savedRange) return;
  const selection = window.getSelection();
  selection.removeAllRanges();
  selection.addRange(savedRange);
}

function runCommand(command, value = null) {
  restoreSelection();
  document.execCommand('styleWithCSS', false, true);
  document.execCommand(command, false, value);
  document.getElementById('item-body').focus();
  saveSelection();
  updatePreview();
}

function applyFontControls() {
  const family = document.getElementById('font-family').value;
  const style = document.getElementById('font-style').value;
  const editor = document.getElementById('item-body');
  if (!family && style === 'regular') return;

  restoreSelection();
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0 || selection.isCollapsed) {
    if (family) editor.style.fontFamily = quoteFont(family);
    return;
  }

  const range = selection.getRangeAt(0);
  const span = document.createElement('span');
  if (family) span.style.fontFamily = quoteFont(family);
  span.style.fontWeight = style.includes('bold') ? '700' : '400';
  span.style.fontStyle = style.includes('italic') ? 'italic' : 'normal';
  span.appendChild(range.extractContents());
  range.insertNode(span);
  selection.removeAllRanges();
  const newRange = document.createRange();
  newRange.selectNodeContents(span);
  selection.addRange(newRange);
  saveSelection();
  updatePreview();
}

function quoteFont(font) {
  return font.includes(' ') ? `"${font}", sans-serif` : `${font}, sans-serif`;
}

function renderContentList() {
  const tbody = document.getElementById('content-list');
  tbody.innerHTML = '';
  sortedItems().forEach((item) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>
        <div class="content-title">${escapeHtml(item.title || item.heroTitle || 'Cím nélkül')}</div>
        <div class="content-slug">${escapeHtml(item.slug || '')}</div>
      </td>
      <td>${TYPE_LABELS[item.type] || item.type}</td>
      <td><span class="badge ${item.status === 'draft' ? 'draft' : 'published'}">${STATUS_LABELS[item.status] || item.status}</span></td>
      <td>${formatDate(item.lastModified)}</td>
      <td>
        <div class="row-actions">
          <button class="btn btn-secondary table-action" type="button" data-edit="${item.id}">Szerkesztés</button>
          <button class="btn btn-danger table-action" type="button" data-delete="${item.id}" ${item.locked ? 'disabled title="A főoldali alapelemek nem törölhetők."' : ''}>Törlés</button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });

  tbody.querySelectorAll('[data-edit]').forEach((button) => {
    button.addEventListener('click', () => editItem(button.dataset.edit));
  });
  tbody.querySelectorAll('[data-delete]').forEach((button) => {
    button.addEventListener('click', () => deleteItem(button.dataset.delete));
  });
}

function sortedItems() {
  const order = { 'home-section': 0, 'system-page': 1, 'blog-post': 2 };
  return [...state.items].sort((a, b) => {
    const typeDiff = (order[a.type] ?? 9) - (order[b.type] ?? 9);
    if (typeDiff) return typeDiff;
    return (a.sort ?? 0) - (b.sort ?? 0) || String(a.title).localeCompare(String(b.title), 'hu');
  });
}

function selectFirstEditableItem() {
  const first = sortedItems()[0];
  if (first) loadItemIntoForm(first);
}

function editItem(id) {
  const item = state.items.find((entry) => entry.id === id);
  if (!item) return;
  loadItemIntoForm(item);
  showView('editor');
}

function loadItemIntoForm(item) {
  currentItemId = item.id;
  document.getElementById('item-id').value = item.id;
  document.getElementById('item-title').value = item.title || '';
  document.getElementById('item-type').value = item.type || 'system-page';
  document.getElementById('item-type').disabled = Boolean(item.locked);
  document.getElementById('item-status').value = item.status || 'published';
  document.getElementById('item-slug').value = item.slug || '';
  document.getElementById('item-slug').readOnly = Boolean(item.locked && item.type === 'home-section');
  document.getElementById('item-hero-title').value = item.heroTitle || item.title || '';
  document.getElementById('item-content-heading').value = item.contentHeading || item.title || '';
  document.getElementById('item-hero-image').value = item.heroImage || 'images/hero-bg.jpg';
  document.getElementById('item-intro').value = item.intro || '';
  document.getElementById('item-body').innerHTML = item.bodyHtml || '<p></p>';
  document.getElementById('seo-title').value = item.seoTitle || '';
  document.getElementById('seo-description').value = item.seoDescription || '';
  document.getElementById('editor-heading').textContent = item.title || 'Tartalom szerkesztése';
  document.getElementById('editor-help').textContent = `${TYPE_LABELS[item.type] || item.type} szerkesztése`;
  updateHeroPreview();
  updatePreview();
}

function readFormItem() {
  const existing = state.items.find((entry) => entry.id === currentItemId) || {};
  const title = document.getElementById('item-title').value.trim() || 'Cím nélkül';
  const type = document.getElementById('item-type').value;
  const slug = document.getElementById('item-slug').value.trim() || `${slugify(title)}.html`;
  const intro = document.getElementById('item-intro').value;
  return {
    ...existing,
    id: existing.id || safeId('item'),
    title,
    type,
    slug,
    status: document.getElementById('item-status').value,
    heroTitle: document.getElementById('item-hero-title').value.trim() || title,
    heroImage: document.getElementById('item-hero-image').value,
    intro,
    cardSummary: type === 'system-page' ? intro : existing.cardSummary,
    contentHeading: document.getElementById('item-content-heading').value.trim() || title,
    bodyHtml: normalizeEditorHtml(document.getElementById('item-body').innerHTML),
    seoTitle: document.getElementById('seo-title').value,
    seoDescription: document.getElementById('seo-description').value,
    lastModified: nowIso()
  };
}

function saveCurrentItem() {
  if (!currentItemId) return;
  const nextItem = readFormItem();
  const index = state.items.findIndex((entry) => entry.id === currentItemId);
  if (index >= 0) state.items[index] = nextItem;
  else state.items.push(nextItem);
  currentItemId = nextItem.id;
  renderContentList();
  updatePreview();
}

function deleteItem(id) {
  const item = state.items.find((entry) => entry.id === id);
  if (!item || item.locked) return;
  if (!confirm(`Törlöd ezt a tartalmat: ${item.title}?`)) return;
  state.items = state.items.filter((entry) => entry.id !== id);
  renderContentList();
  if (currentItemId === id) selectFirstEditableItem();
  saveAll('Sikeresen törölve');
}

function saveAll(successMessage = 'Sikeresen mentve') {
  try {
    if (document.getElementById('editor').classList.contains('active') && currentItemId) {
      saveCurrentItem();
    }
    localStorage.setItem(ADMIN_STORAGE_KEY, JSON.stringify(state));
    localStorage.setItem(LEGACY_STORAGE_KEY, JSON.stringify(buildLegacyContent()));
    showStatus(successMessage);
  } catch (error) {
    console.error(error);
    showStatus('Hiba történt mentés közben', true);
  }
}

function buildLegacyContent() {
  const legacy = {
    ...(typeof DEFAULT_CONTENT !== 'undefined' ? DEFAULT_CONTENT : {}),
    ...(safeJson(localStorage.getItem(LEGACY_STORAGE_KEY)) || {})
  };

  const hero = getItem('home-hero');
  if (hero) {
    legacy.heroTitle = hero.heroTitle || hero.title;
    legacy.heroSubtitle = hero.intro || '';
    legacy.heroButtonText = stripHtml(hero.bodyHtml || '').trim() || hero.ctaText || legacy.heroButtonText;
  }

  const teachings = getItem('home-teachings');
  if (teachings) {
    legacy.teachingsTitle = teachings.heroTitle || teachings.title;
    legacy.teachingsSubtitle = teachings.intro || stripHtml(teachings.bodyHtml || '');
  }

  const pageMap = {
    'system-kundalini': ['kundaliniTitle', 'kundaliniText'],
    'system-mantra': ['mantraTitle', 'mantraText'],
    'system-meditacio': ['meditacioTitle', 'meditacioText'],
    'system-kriya': ['kriyaTitle', 'kriyaText'],
    'system-japji': ['japjiTitle', 'japjiText']
  };
  Object.entries(pageMap).forEach(([id, fields]) => {
    const page = getItem(id);
    if (!page) return;
    legacy[fields[0]] = page.title;
    legacy[fields[1]] = page.cardSummary || page.intro || stripHtml(page.bodyHtml || '').slice(0, 160);
  });

  legacy.blogs = state.items
    .filter((item) => item.type === 'blog-post')
    .map((item, index) => ({
      id: index + 1,
      category: item.category || 'Blog',
      title: item.title,
      description: item.intro || stripHtml(item.bodyHtml || '').slice(0, 160),
      buttonText: item.buttonText || 'Tovább olvasom'
    }));

  return legacy;
}

function getItem(id) {
  return state.items.find((item) => item.id === id);
}

function showStatus(message, isError = false) {
  const status = document.getElementById('save-status');
  status.textContent = message;
  status.classList.toggle('error', isError);
  clearTimeout(showStatus.timer);
  showStatus.timer = setTimeout(() => {
    status.textContent = '';
    status.classList.remove('error');
  }, 3200);
}

function resetAll() {
  if (!confirm('Biztosan visszaállítod az admin tartalmat alaphelyzetbe?')) return;
  localStorage.removeItem(ADMIN_STORAGE_KEY);
  localStorage.removeItem(LEGACY_STORAGE_KEY);
  state = createDefaultState();
  currentItemId = null;
  populateImageSelects();
  renderContentList();
  renderImageLibrary();
  selectFirstEditableItem();
  showStatus('Alaphelyzet visszaállítva');
}

function updatePreview() {
  const title = document.getElementById('item-hero-title').value || document.getElementById('item-title').value || 'Válassz tartalmat';
  const intro = document.getElementById('item-intro').value || 'Az itt szerkesztett tartalom localStorage-ba mentődik.';
  const type = document.getElementById('item-type').value;
  const image = resolveImageSrc(document.getElementById('item-hero-image').value);
  document.getElementById('preview-title').textContent = title;
  document.getElementById('preview-intro').textContent = intro;
  document.getElementById('preview-type').textContent = TYPE_LABELS[type] || type;
  document.getElementById('preview-hero').style.backgroundImage = `linear-gradient(rgba(5,7,12,.12), rgba(5,7,12,.46)), url("${image}")`;
}

function updateHeroPreview() {
  const value = document.getElementById('item-hero-image').value;
  document.getElementById('hero-image-preview').src = resolveImageSrc(value);
  updatePreview();
}

function bindUploader() {
  document.getElementById('image-upload').addEventListener('change', handleUploads);
}

function handleUploads(event) {
  const files = Array.from(event.target.files || []);
  const error = document.getElementById('upload-error');
  error.textContent = '';
  if (!files.length) return;

  const folder = sanitizeFolder(document.getElementById('custom-folder').value || document.getElementById('upload-folder').value);
  const invalid = files.find((file) => !isAllowedImageFile(file));
  if (invalid) {
    error.textContent = `Nem támogatott fájl: ${invalid.name}. Csak jpg, jpeg, png, webp vagy svg tölthető fel.`;
    event.target.value = '';
    return;
  }

  Promise.all(files.map((file) => readImageFile(file, folder)))
    .then((images) => {
      state.images.unshift(...images);
      populateImageSelects();
      renderImageLibrary();
      saveAll('Képek feltöltve');
      event.target.value = '';
    })
    .catch(() => {
      error.textContent = 'Hiba történt feltöltés közben.';
    });
}

function isAllowedImageFile(file) {
  const allowed = ['jpg', 'jpeg', 'png', 'webp', 'svg'];
  const extension = file.name.split('.').pop().toLowerCase();
  const hasAllowedExtension = allowed.includes(extension);
  const hasImageMime = !file.type || file.type.startsWith('image/');
  return hasAllowedExtension && hasImageMime;
}

function readImageFile(file, folder) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '-');
      resolve({
        id: safeId('image'),
        fileName: safeName,
        folder,
        path: `${folder}/${safeName}`,
        src: reader.result,
        uploadedAt: nowIso()
      });
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function sanitizeFolder(value) {
  return slugify(value || 'uploads');
}

function renderImageLibrary() {
  const library = document.getElementById('image-library');
  const images = allImages();
  if (!images.length) {
    library.innerHTML = '<p class="image-meta">Még nincs kép feltöltve.</p>';
    return;
  }
  library.innerHTML = images.map((image) => `
    <article class="image-card">
      <img src="${escapeAttr(resolveImageSrc(image.path))}" alt="">
      <div class="image-card-body">
        <strong title="${escapeAttr(image.fileName)}">${escapeHtml(image.fileName)}</strong>
        <span class="image-meta">Mappa: ${escapeHtml(image.folder)}</span>
        <span class="image-url">${escapeHtml(image.path)}</span>
        <button class="btn btn-secondary table-action" type="button" data-copy="${escapeAttr(image.path)}">URL másolása</button>
      </div>
    </article>
  `).join('');

  library.querySelectorAll('[data-copy]').forEach((button) => {
    button.addEventListener('click', () => copyText(button.dataset.copy));
  });
}

function populateImageSelects() {
  const options = allImages().map((image) => `<option value="${escapeAttr(image.path)}">${escapeHtml(image.path)}</option>`).join('');
  document.getElementById('item-hero-image').innerHTML = options;
  document.getElementById('inline-image-select').innerHTML = options;
}

function allImages() {
  return [...EXISTING_IMAGES, ...(state?.images || [])];
}

function resolveImageSrc(path) {
  const image = allImages().find((entry) => entry.path === path);
  return image?.src || path || 'images/hero-bg.jpg';
}

function insertSelectedImageIntoEditor() {
  const select = document.getElementById('inline-image-select');
  const src = resolveImageSrc(select.value);
  restoreSelection();
  document.execCommand('insertHTML', false, `<img src="${escapeAttr(src)}" alt="" style="max-width:100%;height:auto;border-radius:10px;">`);
  saveSelection();
  updatePreview();
}

function copyText(value) {
  if (navigator.clipboard) {
    navigator.clipboard.writeText(value)
      .then(() => showStatus('URL másolva'))
      .catch(() => fallbackCopyText(value));
  } else {
    fallbackCopyText(value);
  }
}

function fallbackCopyText(value) {
  const textarea = document.createElement('textarea');
  textarea.value = value;
  textarea.setAttribute('readonly', '');
  textarea.style.position = 'fixed';
  textarea.style.left = '-9999px';
  document.body.appendChild(textarea);
  textarea.select();
  const copied = document.execCommand('copy');
  textarea.remove();
  showStatus(copied ? 'URL másolva' : value);
}

function normalizeEditorHtml(html) {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = html || '';
  wrapper.querySelectorAll('img').forEach((img) => {
    img.style.maxWidth = '100%';
    img.style.height = 'auto';
    img.style.borderRadius = '10px';
  });
  return wrapper.innerHTML.trim();
}

function stripHtml(html) {
  const div = document.createElement('div');
  div.innerHTML = html || '';
  return div.textContent || div.innerText || '';
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeAttr(value) {
  return escapeHtml(value).replace(/`/g, '&#096;');
}
