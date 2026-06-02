document.addEventListener('DOMContentLoaded', () => {
  const nav = document.querySelector('.navbar');
  const hamburger = document.querySelector('.hamburger');
  const navLinks = document.querySelector('.nav-links');
  const navItems = document.querySelectorAll('.nav-links a');
  applyAdminContent();

  window.addEventListener('scroll', () => {
    if (!nav) return;
    nav.classList.toggle('scrolled', window.scrollY > 50);
  }, { passive: true });

  if (hamburger && navLinks) {
    hamburger.addEventListener('click', () => {
      hamburger.classList.toggle('active');
      navLinks.classList.toggle('active');
    });
  }

  navItems.forEach((item) => {
    item.addEventListener('click', () => {
      hamburger?.classList.remove('active');
      navLinks?.classList.remove('active');
    });
  });
});

function applyAdminContent() {
  const adminState = readJson(localStorage.getItem('gurnamAdminContent'));
  if (!adminState || !Array.isArray(adminState.items)) return;

  const currentSlug = decodeURIComponent(window.location.pathname.split('/').pop());
  const item = adminState.items.find((entry) => entry.slug === currentSlug && entry.type === 'system-page');
  if (!item || item.status === 'draft') return;

  const heroImage = document.querySelector('.subpage-hero img');
  const heroTitle = document.querySelector('.subpage-hero-content h1');
  const heroIntro = document.querySelector('.subpage-hero-content p');
  const content = document.querySelector('.page-content-inner');

  if (item.seoTitle) document.title = item.seoTitle;
  const meta = document.querySelector('meta[name="description"]');
  if (meta && item.seoDescription) meta.setAttribute('content', item.seoDescription);

  if (heroImage && item.heroImage) {
    heroImage.src = resolveImageSrc(adminState, item.heroImage);
  }
  if (heroTitle) heroTitle.textContent = item.heroTitle || item.title;
  if (heroIntro) heroIntro.textContent = item.intro || '';
  if (content) {
    content.innerHTML = `
      <h2>${escapeHtml(item.contentHeading || item.title)}</h2>
      <div class="admin-rendered-content">${item.bodyHtml || ''}</div>
      <div class="content-note">
        <p>Ez a tartalom az admin felületen szerkeszthető.</p>
      </div>
      <a href="index.html#tanitasok" class="back-link">← Vissza a tanításokhoz</a>
    `;
  }
}

function resolveImageSrc(adminState, path) {
  const uploaded = (adminState.images || []).find((image) => image.path === path);
  return uploaded?.src || path;
}

function readJson(value) {
  try {
    return value ? JSON.parse(value) : null;
  } catch {
    return null;
  }
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
