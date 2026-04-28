<script>
(function () {
  const OFFSET = 80;

  function normaliseText(text) {
    return (text || '').replace(/\s+/g, ' ').trim();
  }

  function collectHeadings() {
    return Array.from(document.querySelectorAll(
      '.post-body h1, .post-body h2, .post-body h3, .post-body h4, .post-body h5, .post-body h6'
    )).map(function (heading) {
      const spanWithId = heading.querySelector('span[id]');
      const id = heading.id || (spanWithId && spanWithId.id);
      const text = normaliseText(heading.textContent);

      // 把 id 从内部 span 复制到 h1/h2/h3 本身，方便浏览器和脚本定位
      if (id && !heading.id) {
        heading.id = id;
      }

      return { heading, id, text };
    }).filter(function (item) {
      return item.id && item.text;
    });
  }

  function patchTocLinks() {
    const headings = collectHeadings();
    const byText = new Map();

    headings.forEach(function (item) {
      if (!byText.has(item.text)) {
        byText.set(item.text, item);
      }
    });

    const links = Array.from(document.querySelectorAll('.post-toc a.nav-link'));

    links.forEach(function (link, index) {
      const text = normaliseText(link.textContent);
      const matched = byText.get(text) || headings[index];

      if (!matched || !matched.id) return;

      link.setAttribute('href', '#' + matched.id);
      link.dataset.targetId = matched.id;
      link.style.cursor = 'pointer';
    });
  }

  function scrollToHeading(id) {
    const target = document.getElementById(id);
    if (!target) return false;

    const top = target.getBoundingClientRect().top + window.pageYOffset - OFFSET;

    window.scrollTo({
      top: top,
      behavior: 'smooth'
    });

    // 更新地址栏 hash，但不触发默认跳转
    if (history.replaceState) {
      history.replaceState(null, '', '#' + id);
    } else {
      location.hash = id;
    }

    return true;
  }

  function bindTocClicks() {
    document.querySelectorAll('.post-toc a.nav-link').forEach(function (link) {
      if (link.dataset.tocFixed === 'true') return;
      link.dataset.tocFixed = 'true';

      link.addEventListener('click', function (event) {
        const id = link.dataset.targetId || decodeURIComponent(
          (link.getAttribute('href') || '').replace(/^#/, '')
        );

        if (id && scrollToHeading(id)) {
          event.preventDefault();
          event.stopPropagation();
          event.stopImmediatePropagation();
        }
      }, true);
    });
  }

  function fixToc() {
    patchTocLinks();
    bindTocClicks();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fixToc);
  } else {
    fixToc();
  }

  window.addEventListener('load', fixToc);
  document.addEventListener('pjax:success', function () {
    setTimeout(fixToc, 0);
  });

  // 兜底：等 NexT motion / sidebar 初始化完成后再修一次
  setTimeout(fixToc, 300);
  setTimeout(fixToc, 1000);
})();
</script>