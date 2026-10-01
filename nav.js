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
    '            <a href="case-study-1.html">Research &amp; Design at Next</a>',
    '            <a href="design-system.html">A Design System Built in Code</a>',
    '          </div>',
    '        </div>',
    '        <div class="nav-dropdown">',
    '          <span class="nav-dropdown-trigger">Contact</span>',
    '          <div class="dropdown-menu">',
    '            <span class="dropdown-label">Get in touch</span>',
    '            <a href="#" id="nav-email-link">dwlkr [at] me.com</a>',
    '            <a href="tel:+447885725355">+44 7885 725355</a>',
    '            <span class="dropdown-label" style="margin-top:4px;">More</span>',
    '            <a href="cv.html">CV</a>',
    '          </div>',
    '        </div>',
    '      </div>',
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
  if (page.indexOf('case-study') === 0 || page === 'design-system.html') {
    var projectsDropdown = document.querySelectorAll('#main-nav .nav-dropdown');
    if (projectsDropdown.length > 0) {
      var trigger = projectsDropdown[0].querySelector('.nav-dropdown-trigger');
      if (trigger) trigger.classList.add('active');
    }
  }

  // On cv.html, give the Contact trigger the active pill style
  if (page === 'cv.html') {
    var navDropdowns = document.querySelectorAll('#main-nav .nav-dropdown');
    if (navDropdowns.length > 1) {
      var contactTrigger = navDropdowns[1].querySelector('.nav-dropdown-trigger');
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
