(function () {
  'use strict';

  var NAV_HTML = [
    '<nav id="main-nav">',
    '  <div class="nav-inner">',
    '    <div class="nav-left">',
    '      <div class="nav-links">',
    '        <a href="index.html">Home</a>',
    '        <div class="nav-dropdown">',
    '          <span class="nav-dropdown-trigger">Projects</span>',
    '          <div class="dropdown-menu">',
    '            <span class="dropdown-label">Case Studies</span>',
    '            <a href="case-study-1.html">Modernising Warehouse Operations</a>',
    '            <a href="case-study-2.html">Building a Social Media App</a>',
    '            <span class="dropdown-label" style="margin-top:4px;">Mini Projects</span>',
    '            <a href="case-study-3.html">Pass &amp; Play Game Design in iOS</a>',
    '          </div>',
    '        </div>',
    '        <div class="nav-dropdown">',
    '          <span class="nav-dropdown-trigger">Contact</span>',
    '          <div class="dropdown-menu">',
    '            <span class="dropdown-label">Get in touch</span>',
    '            <a href="#" id="nav-email-link">dwlkr [at] me.com</a>',
    '            <span class="dropdown-label" style="margin-top:4px;">More</span>',
    '            <a href="cv.html">CV</a>',
    '          </div>',
    '        </div>',
    '      </div>',
    '    </div>',
    '    <div class="nav-right">',
    '      <button class="theme-toggle" id="theme-toggle" aria-label="Toggle dark mode">',
    '        <svg id="icon-sun" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="display:none;">',
    '          <circle cx="12" cy="12" r="4"/>',
    '          <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>',
    '        </svg>',
    '        <svg id="icon-moon" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">',
    '          <path d="M21 12.79A9 9 0 1 1 11.21 3a7 7 0 0 0 9.79 9.79z"/>',
    '        </svg>',
    '      </button>',
    '    </div>',
    '  </div>',
    '</nav>'
  ].join('\n');

  // Inject nav — replace #nav-mount if present, otherwise prepend to body
  var mount = document.getElementById('nav-mount');
  if (mount) {
    mount.outerHTML = NAV_HTML;
  } else {
    document.body.insertAdjacentHTML('afterbegin', NAV_HTML);
  }

  // ── Theme ──────────────────────────────────────────────────────────────────
  function applyTheme(dark) {
    document.documentElement.classList.toggle('dark', dark);
    var sun  = document.getElementById('icon-sun');
    var moon = document.getElementById('icon-moon');
    if (sun)  sun.style.display  = dark ? 'block' : 'none';
    if (moon) moon.style.display = dark ? 'none'  : 'block';
  }

  applyTheme(localStorage.getItem('theme') === 'dark');

  var toggle = document.getElementById('theme-toggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      var isDark = !document.documentElement.classList.contains('dark');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
      applyTheme(isDark);
    });
  }

  // ── Email obfuscation ──────────────────────────────────────────────────────
  var navEmail = document.getElementById('nav-email-link');
  if (navEmail) {
    var e = 'dwlkr' + '@' + 'me.com';
    navEmail.href = 'mailto:' + e;
    navEmail.textContent = e;
  }

  // ── Active nav state ───────────────────────────────────────────────────────
  var page = window.location.pathname.split('/').pop() || 'index.html';
  if (page === '') page = 'index.html';

  // Mark Home active on index
  var homeLink = document.querySelector('#main-nav .nav-links > a[href="index.html"]');
  if (homeLink && page === 'index.html') {
    homeLink.classList.add('active');
  }

  // On case study pages, give the Projects trigger the active pill style
  if (page.indexOf('case-study') === 0) {
    var projectsDropdown = document.querySelectorAll('#main-nav .nav-dropdown');
    if (projectsDropdown.length > 0) {
      var trigger = projectsDropdown[0].querySelector('.nav-dropdown-trigger');
      if (trigger) trigger.classList.add('active');
    }
  }

  // On cv.html, give the Contact trigger the active pill style
  if (page === 'cv.html') {
    var allDropdowns = document.querySelectorAll('#main-nav .nav-dropdown');
    if (allDropdowns.length > 1) {
      var contactTrigger = allDropdowns[1].querySelector('.nav-dropdown-trigger');
      if (contactTrigger) contactTrigger.classList.add('active');
    }
  }

  // ── Dropdown touch/click support ──────────────────────────────────────────
  var dropdowns = document.querySelectorAll('#main-nav .nav-dropdown');

  dropdowns.forEach(function (dd) {
    var trigger = dd.querySelector('.nav-dropdown-trigger');
    if (!trigger) return;

    trigger.addEventListener('click', function (e) {
      var isOpen = dd.classList.contains('open');
      // Close all other dropdowns
      dropdowns.forEach(function (other) { other.classList.remove('open'); });
      // Toggle this one
      if (!isOpen) dd.classList.add('open');
    });
  });

  // Close dropdowns when tapping outside
  document.addEventListener('click', function (e) {
    if (!e.target.closest('#main-nav .nav-dropdown')) {
      dropdowns.forEach(function (dd) { dd.classList.remove('open'); });
    }
  });

  // Close dropdowns on link click (so menu collapses after navigating)
  document.querySelectorAll('#main-nav .dropdown-menu a').forEach(function (link) {
    link.addEventListener('click', function () {
      dropdowns.forEach(function (dd) { dd.classList.remove('open'); });
    });
  });

  // ── Scroll hide / show ─────────────────────────────────────────────────────
  var lastY = 0;
  window.addEventListener('scroll', function () {
    var nav = document.getElementById('main-nav');
    if (!nav) return;
    var y = window.scrollY;
    if (y > lastY && y > 80) {
      nav.classList.add('hidden-nav');
    } else {
      nav.classList.remove('hidden-nav');
    }
    nav.classList.toggle('scrolled', y > 10);
    lastY = y;
  }, { passive: true });

})();
