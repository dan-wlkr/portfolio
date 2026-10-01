// Shared case study motion — loader, word reveals, scroll reveals, glow.
(function () {
  'use strict';

  var root = document.documentElement;
  var STEP = 0.045;

  // ── Word reveal ──────────────────────────────────────────────────────────
  function splitWords(el) {
    var delay = parseFloat(el.dataset.delay || 0);
    var units = [];
    el.childNodes.forEach(function (node) {
      if (node.nodeType === 3) {
        node.textContent.trim().split(/\s+/).filter(Boolean).forEach(function (w) { units.push({ text: w }); });
      } else if (node.nodeName === 'BR') {
        units.push({ raw: node.outerHTML });
      } else if (node.nodeType === 1) {
        units.push({ html: node.outerHTML });
      }
    });
    el.innerHTML = units.map(function (u, i) {
      if (u.raw) return u.raw;
      var inner = u.html || u.text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      return '<span class="wr-word" style="transition-delay:' + (delay + i * STEP).toFixed(3) + 's">' + inner + '</span>';
    }).join(' ');

    // Elements listed in data-after start once the last word lands
    var end = delay + units.length * STEP + 0.3;
    (el.dataset.after || '').split(/\s+/).filter(Boolean).forEach(function (id, i) {
      var t = document.getElementById(id);
      if (t) t.style.setProperty('--d', (end + i * 0.12).toFixed(2) + 's');
    });
  }

  // Section titles reveal word by word; the rest of the section follows
  // Flow diagram nodes are skipped: its connector lines are measured from them
  document.querySelectorAll('.scroll-fade:not(.flow-node)').forEach(function (el) {
    var title = el.matches('section') && el.querySelector(':scope > .section-title');
    if (title) {
      title.classList.add('word-reveal');
      var i = 0;
      Array.prototype.forEach.call(el.children, function (child) {
        if (child === title) return;
        child.setAttribute('data-reveal', '');
        child.style.setProperty('--d', Math.min(0.35 + i++ * 0.08, 0.8).toFixed(2) + 's');
      });
    } else {
      el.setAttribute('data-reveal', '');
    }
    el.setAttribute('data-observe', '');
  });
  document.querySelectorAll('.word-reveal').forEach(splitWords);

  // ── Scroll reveals ───────────────────────────────────────────────────────
  function observeReveals() {
    var targets = document.querySelectorAll('[data-observe]');
    if (!('IntersectionObserver' in window)) {
      targets.forEach(function (el) { el.classList.add('in'); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      var batch = 0;
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var el = entry.target;
        // Blocks that arrive together stagger slightly
        if (el.hasAttribute('data-reveal') && !el.style.getPropertyValue('--d')) {
          el.style.setProperty('--d', (batch * 0.1).toFixed(2) + 's');
        }
        batch++;
        el.classList.add('in');
        io.unobserve(el);
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });
    targets.forEach(function (el) { io.observe(el); });
  }

  // ── Background glow ──────────────────────────────────────────────────────
  var glow = document.querySelector('.bg-glow');
  if (glow) {
    var first = document.querySelector('[data-glow]');
    if (first) {
      var c0 = first.dataset.glow.split('|');
      glow.style.setProperty('--c1', c0[0]);
      glow.style.setProperty('--c2', c0[1]);
    }
    if ('IntersectionObserver' in window) {
      var glowObs = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          var c = entry.target.dataset.glow.split('|');
          glow.style.setProperty('--c1', c[0]);
          glow.style.setProperty('--c2', c[1]);
        });
      }, { rootMargin: '-45% 0px -45% 0px' });
      document.querySelectorAll('[data-glow]').forEach(function (el) { glowObs.observe(el); });
    }
    var ticking = false;
    window.addEventListener('scroll', function () {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function () {
        var max = document.documentElement.scrollHeight - window.innerHeight;
        glow.style.setProperty('--p', max > 0 ? (window.scrollY / max).toFixed(3) : 0);
        ticking = false;
      });
    }, { passive: true });
  }

  // ── Email links ──────────────────────────────────────────────────────────
  var email = 'dwlkr' + '@' + 'me.com';
  document.querySelectorAll('.js-email').forEach(function (a) { a.href = 'mailto:' + email; });
  var footerEmail = document.getElementById('footer-email-link');
  if (footerEmail) { footerEmail.href = 'mailto:' + email; footerEmail.textContent = email; }

  // ── Loader — wait for the hero image and fonts (capped), then play in ────
  var bar = document.querySelector('.loader-bar i');
  var critical = Array.prototype.slice.call(document.querySelectorAll('.cs-hero-img img'));
  var total = critical.length + 1, done = 0, started = Date.now(), finished = false;

  function tick() {
    done++;
    if (bar) bar.style.setProperty('--progress', Math.min(done / total, 1));
    if (done >= total) finish();
  }
  function finish() {
    if (finished) return;
    finished = true;
    var wait = Math.max(0, 700 - (Date.now() - started));
    setTimeout(function () {
      if (bar) bar.style.setProperty('--progress', 1);
      setTimeout(function () {
        root.classList.remove('is-loading');
        root.classList.add('is-ready');
        setTimeout(function () {
          var hero = document.getElementById('hero-main');
          if (hero) hero.classList.add('in');
        }, 250);
        setTimeout(function () { root.classList.add('nav-ready'); }, 1100);
        setTimeout(observeReveals, 900);
      }, 300);
    }, wait);
  }

  critical.forEach(function (img) {
    if (img.complete) tick();
    else { img.addEventListener('load', tick, { once: true }); img.addEventListener('error', tick, { once: true }); }
  });
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(tick, tick); else tick();
  setTimeout(finish, 4000);
})();
