import re

with open('index.html', 'r') as f:
    content = f.read()

# 1. Add Carousel CSS
css_to_add = """
        /* Carousel */
        .carousel-wrapper { position: relative; padding: 0 10px; }
        .carousel-track { display: flex; gap: 2.5rem; overflow-x: auto; scroll-snap-type: x mandatory; scrollbar-width: none; -ms-overflow-style: none; padding: 20px 0; }
        .carousel-track::-webkit-scrollbar { display: none; }
        .carousel-slide { flex: 0 0 100%; scroll-snap-align: center; }
        @media (min-width: 768px) { .carousel-slide { flex: 0 0 calc(50% - 1.25rem); } }
        @media (min-width: 1024px) { .carousel-slide { flex: 0 0 calc(33.333% - 1.666rem); } }
        .carousel-btn { position: absolute; top: 50%; transform: translateY(-50%); background: var(--color-white); border: 1px solid var(--color-gold); color: var(--color-gold); width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; z-index: 10; box-shadow: var(--shadow-sm); transition: var(--transition); font-size: 1.2rem; }
        .carousel-btn:hover { background: var(--color-gold); color: var(--color-white); }
        .carousel-btn.prev { left: -15px; }
        .carousel-btn.next { right: -15px; }
"""
content = content.replace("/* Navigation */", css_to_add + "\n        /* Navigation */")

# 2. Add IDs to Hero
content = content.replace("<h1>Ébredj a saját belső erődre</h1>", "<h1 id=\"heroTitle\">Ébredj a saját belső erődre</h1>")
content = content.replace("<p>Modern, tiszta és mély Kundalini jóga gyakorlás. Lépj be a csendbe, és találd meg a válaszokat\n                önmagadban.</p>", "<p id=\"heroSubtitle\">Modern, tiszta és mély Kundalini jóga gyakorlás. Lépj be a csendbe, és találd meg a válaszokat önmagadban.</p>")
content = content.replace("<a href=\"#orarend\" class=\"btn btn-primary\">Következő óra</a>", "<a href=\"#orarend\" class=\"btn btn-primary\" id=\"heroButtonText\">Részletek</a>")
content = content.replace("<a href=\"#orarend\" class=\"mobile-cta\">Jelentkezés</a>", "<a href=\"#orarend\" class=\"mobile-cta\" id=\"mobileCtaText\">Érdeklődöm</a>")

# 3. Add IDs to Teachings
content = content.replace("<h2>A Rendszer</h2>", "<h2 id=\"teachingsTitle\">A Rendszer</h2>")
content = content.replace("<p>A Kundalini jóga egy ősi, átfogó tudomány, amely fizikai gyakorlatokat, légzéstechnikákat, mantrákat\n                    és meditációt ötvöz a tudatosság emelésére.</p>", "<p id=\"teachingsSubtitle\">A Kundalini jóga egy ősi, átfogó tudomány, amely fizikai gyakorlatokat, légzéstechnikákat, mantrákat és meditációt ötvöz a tudatosság emelésére.</p>")

content = content.replace("<h3>Kundalini Jóga</h3>\n                        <p>Dinamikus mozgás és légzés a kreatív életenergia felébresztésére és áramoltatására a testben.</p>", "<h3 id=\"kundaliniTitle\">Kundalini Jóga</h3>\n                        <p id=\"kundaliniText\">Dinamikus mozgás és légzés a kreatív életenergia felébresztésére és áramoltatására a testben.</p>")
content = content.replace("<h3>Mantra</h3>\n                        <p>Szent hangrezgések használata az elme lecsendesítésére és az idegrendszer finomhangolására.</p>", "<h3 id=\"mantraTitle\">Mantra</h3>\n                        <p id=\"mantraText\">Szent hangrezgések használata az elme lecsendesítésére és az idegrendszer finomhangolására.</p>")
content = content.replace("<h3>Meditáció</h3>\n                        <p>A jelenlét mély megtapasztalása, a belső figyelem fókuszálása és az elme megtisztítása.</p>", "<h3 id=\"meditacioTitle\">Meditáció</h3>\n                        <p id=\"meditacioText\">A jelenlét mély megtapasztalása, a belső figyelem fókuszálása és az elme megtisztítása.</p>")
content = content.replace("<h3>Kriya</h3>\n                        <p>Célzott gyakorlatsorok, amelyek specifikus fizikai, érzelmi vagy mentális hatást érnek el.</p>", "<h3 id=\"kriyaTitle\">Kriya</h3>\n                        <p id=\"kriyaText\">Célzott gyakorlatsorok, amelyek specifikus fizikai, érzelmi vagy mentális hatást érnek el.</p>")
content = content.replace("<h3>Japji Sahib</h3>\n                        <p>A lélek éneke, hajnali spirituális fegyelem és mély meditációs szöveg a belső harmóniáért.</p>", "<h3 id=\"japjiTitle\">Japji Sahib</h3>\n                        <p id=\"japjiText\">A lélek éneke, hajnali spirituális fegyelem és mély meditációs szöveg a belső harmóniáért.</p>")

# 4. Add IDs to Schedule and dynamic container
content = content.replace("<h2>Órarend</h2>", "<h2 id=\"scheduleTitle\">Órarend</h2>")
content = content.replace("<p>Csatlakozz rendszeres óráinkhoz személyesen Budapesten vagy online a világ bármely pontjáról.</p>", "<p id=\"scheduleSubtitle\">Csatlakozz rendszeres óráinkhoz személyesen Budapesten.</p>")

schedule_start = content.find('<div class="schedule-container">')
schedule_end = content.find('</div>\n        </div>\n    </section>\n\n    <!-- Programok (Programs) -->')
schedule_str = content[schedule_start:schedule_end]
content = content.replace(schedule_str, '<div class="schedule-container" id="dynamic-schedule-container"></div>')

# 5. Add IDs to Events and dynamic carousel
content = content.replace("<h2>Események és Programok</h2>", "<h2 id=\"eventsTitle\">Események és Programok</h2>")
content = content.replace("<p>Mélyítsd el a gyakorlásod tematikus workshopjainkon és elvonulásainkon.</p>", "<p id=\"eventsSubtitle\">Mélyítsd el a gyakorlásod tematikus workshopjainkon és elvonulásainkon.</p>")

events_start = content.find('<div class="cards-grid">')
events_end = content.find('</div>\n        </div>\n    </section>\n\n    <!-- Írások (Blog) -->')
events_str = content[events_start:events_end]
carousel_html = """<div class="carousel-wrapper">
                <button class="carousel-btn prev" id="carousel-prev">&larr;</button>
                <button class="carousel-btn next" id="carousel-next">&rarr;</button>
                <div class="carousel-track" id="dynamic-events-track"></div>
            </div>"""
content = content.replace(events_str, carousel_html)

# 6. Add IDs to Blog
content = content.replace("<h2>Írások</h2>", "<h2 id=\"blogTitle\">Írások</h2>")
content = content.replace("<p>Gondolatok, tapasztalatok és mélyebb tanítások a Kundalini jógáról és a tudatos életről.</p>", "<p id=\"blogSubtitle\">Gondolatok, tapasztalatok és mélyebb tanítások a Kundalini jógáról és a tudatos életről.</p>")
blog_start = content.find('<div class="cards-grid">', events_end)
blog_end = content.find('</div>\n        </div>\n    </section>\n\n    <!-- Rólam (About) -->')
blog_str = content[blog_start:blog_end]
content = content.replace(blog_str, '<div class="cards-grid" id="dynamic-blogs-grid"></div>')

# 7. Add IDs to About
content = content.replace("<h2><span>Utam</span> a csendhez</h2>", "<h2><span id=\"aboutTitle1\">Utam</span> <span id=\"aboutTitle2\">a csendhez</span></h2>")
content = content.replace("<p>Gurnam vagyok, nemzetközileg minősített Kundalini jóga és meditáció oktató. A gyakorlás több mint\n                        egy évtizede formálja az életemet, megtanított a jelenlétre, az elfogadásra és arra, hogyan\n                        merítsek erőt önmagamból.</p>", "<p id=\"aboutText1\">Gurnam vagyok...</p>")
content = content.replace("<p>Óráimon letisztult, sallangmentes formában adom át a tanításokat, fókuszban az idegrendszer\n                        kiegyensúlyozásával és a mentális tisztánlátás megteremtésével. Hiszem, hogy mindenki képes\n                        felébreszteni a saját belső potenciálját, ha megkapja hozzá a megfelelő eszközöket és teret.</p>", "<p id=\"aboutText2\">Óráimon letisztult...</p>")
content = content.replace("<div class=\"signature\">Gurnam</div>", "<div class=\"signature\" id=\"aboutSignature\">Gurnam</div>")

# 8. Add IDs to Contact
content = content.replace("<h2>Lépj kapcsolatba</h2>", "<h2 id=\"contactTitle\">Lépj kapcsolatba</h2>")
content = content.replace("<p>Kérdésed van egy órával kapcsolatban? Vagy magánórára jelentkeznél? Írj nekem bátran.</p>", "<p id=\"contactSubtitle\">Kérdésed van egy órával kapcsolatban? Vagy magánórára jelentkeznél? Írj nekem bátran.</p>")
content = content.replace("<h3>Információk</h3>", "<h3 id=\"contactInfoTitle\">Információk</h3>")
content = content.replace("<p>hello@gurnamjoga.hu</p>", "<p id=\"contactEmail\">hello@gurnamjoga.hu</p>")
content = content.replace("<p>+36 30 123 4567</p>", "<p id=\"contactPhone\">+36 30 123 4567</p>")
content = content.replace("<p>Budapest, 1051<br>Harmónia Stúdió</p>", "<p id=\"contactLocation\">Budapest, 1051<br>Harmónia Stúdió</p>")

# 9. Add IDs to Footer
content = content.replace("&copy; 2023 Gurnam Kundalini Jóga. Minden jog fenntartva.", "<span id=\"footerCopyright\">&copy; 2023 Gurnam Kundalini Jóga. Minden jog fenntartva.</span><br><br><a href=\"admin.html\" style=\"font-size:0.8rem;opacity:0.5;text-decoration:underline;\">Admin szerkesztő</a>")

# 10. Add initialization script
init_script = """
    <!-- Data Initialization Script -->
    <script src="data.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const savedData = localStorage.getItem('websiteContent');
            const appData = savedData ? JSON.parse(savedData) : DEFAULT_CONTENT;

            const textFields = [
                'heroTitle', 'heroSubtitle', 'heroButtonText',
                'teachingsTitle', 'teachingsSubtitle',
                'kundaliniTitle', 'kundaliniText', 'mantraTitle', 'mantraText', 'meditacioTitle', 'meditacioText', 'kriyaTitle', 'kriyaText', 'japjiTitle', 'japjiText',
                'scheduleTitle', 'scheduleSubtitle',
                'eventsTitle', 'eventsSubtitle',
                'blogTitle', 'blogSubtitle',
                'aboutTitle1', 'aboutTitle2', 'aboutText1', 'aboutText2', 'aboutSignature',
                'contactTitle', 'contactSubtitle', 'contactInfoTitle', 'contactEmail', 'contactPhone', 'contactLocation',
                'footerCopyright'
            ];

            textFields.forEach(field => {
                const el = document.getElementById(field);
                if (el && appData[field] !== undefined) {
                    el.innerHTML = appData[field].replace(/\\n/g, '<br>');
                }
            });

            // Populate Schedule
            const scheduleContainer = document.getElementById('dynamic-schedule-container');
            if (scheduleContainer && appData.schedule) {
                const nextClass = appData.schedule.find(s => s.highlighted) || appData.schedule[0] || {};
                const otherClasses = appData.schedule.filter(s => s !== nextClass);

                let html = '';
                if (nextClass.title) {
                    html += `
                        <div class="next-class-card fade-up visible">
                            <div class="next-class-tag">Kiemelt / Következő Óra</div>
                            <div>
                                <h3>${nextClass.title}</h3>
                                <div class="next-class-details">
                                    <p><i>📅</i> ${nextClass.day}, ${nextClass.time}</p>
                                    <p><i>📍</i> ${nextClass.location}</p>
                                    <p><i>⏱️</i> ${nextClass.duration}</p>
                                    <p><i>🧘‍♀️</i> ${nextClass.description}</p>
                                </div>
                                <a href="#kapcsolat" class="btn btn-primary" style="width: 100%; text-align: center;">Érdeklődöm</a>
                            </div>
                        </div>
                    `;
                }
                
                html += '<div class="schedule-list">';
                otherClasses.forEach((c, i) => {
                    html += `
                        <div class="schedule-item fade-up visible delay-${(i%3)+1}">
                            <div style="display: flex; gap: 2rem; align-items: center; flex-wrap: wrap;">
                                <div class="schedule-time">${c.day} ${c.time}</div>
                                <div class="schedule-info">
                                    <h4>${c.title}</h4>
                                    <p>${c.location} • ${c.duration}</p>
                                    <p style="font-size:0.8rem;opacity:0.6">${c.description}</p>
                                </div>
                            </div>
                            <a href="#kapcsolat" class="schedule-action">Részletek &rarr;</a>
                        </div>
                    `;
                });
                html += '</div>';
                scheduleContainer.innerHTML = html;
            }

            // Populate Events Carousel
            const eventsContainer = document.getElementById('dynamic-events-track');
            if (eventsContainer && appData.events) {
                let html = '';
                appData.events.forEach((e, i) => {
                    const imgStyle = e.image ? `background: linear-gradient(135deg, rgba(30,41,59,0.3), rgba(15,23,42,0.8)), url('${e.image}') center/cover no-repeat;` : `background: linear-gradient(135deg, #1e293b, #0F172A);`;
                    html += `
                        <div class="carousel-slide fade-up visible delay-${(i%3)+1}">
                            <div class="card" style="height:100%;">
                                <div class="card-img-placeholder" style="${imgStyle} height: 220px;"></div>
                                <div class="card-content">
                                    <div class="card-meta">${e.date}</div>
                                    <h3>${e.title}</h3>
                                    <p>${e.description}</p>
                                    <a href="#kapcsolat" class="card-link">${e.buttonText || 'Érdeklődöm'} &rarr;</a>
                                </div>
                            </div>
                        </div>
                    `;
                });
                eventsContainer.innerHTML = html;
                
                // Initialize Carousel
                const track = eventsContainer;
                const slides = Array.from(track.children);
                const nextButton = document.getElementById('carousel-next');
                const prevButton = document.getElementById('carousel-prev');
                
                if (slides.length > 0) {
                    nextButton.addEventListener('click', () => {
                        const slideWidth = slides[0].getBoundingClientRect().width;
                        track.scrollBy({ left: slideWidth + 40, behavior: 'smooth' });
                    });

                    prevButton.addEventListener('click', () => {
                        const slideWidth = slides[0].getBoundingClientRect().width;
                        track.scrollBy({ left: -(slideWidth + 40), behavior: 'smooth' });
                    });
                }
            }

            // Populate Blogs
            const blogsContainer = document.getElementById('dynamic-blogs-grid');
            if (blogsContainer && appData.blogs) {
                let html = '';
                appData.blogs.forEach((b, i) => {
                    html += `
                        <div class="card fade-up visible delay-${(i%3)+1}">
                            <div class="card-img-placeholder gradient-${(i%3)+1}"></div>
                            <div class="card-content">
                                <div class="card-meta">${b.category}</div>
                                <h3>${b.title}</h3>
                                <p>${b.description}</p>
                                <a href="#kapcsolat" class="card-link">${b.buttonText || 'Tovább olvasom'} &rarr;</a>
                            </div>
                        </div>
                    `;
                });
                blogsContainer.innerHTML = html;
            }
        });
    </script>
</body>
"""

content = content.replace("</body>", init_script)

with open('index.html', 'w') as f:
    f.write(content)
