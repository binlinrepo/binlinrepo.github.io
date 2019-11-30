document.addEventListener('DOMContentLoaded', function () {
  var ias = $.ias({
    container: '.posts',
    item: '.post',
    pagination: '.pager-next-url',
    next: '.pager-next-url'
  })
  ias.on('loaded', function (data, items) {
    console.log('loaded:', items)
    if (window.MathJax) MathJax.Hub.Queue(['Typeset', MathJax.Hub])
  })
  ias.extension(new IASSpinnerExtension({
    src: '/assets/img/loading.gif'
  }))
  ias.extension(new IASNoneLeftExtension({
    text: '只有这些了~',
    html: '<div class="ias-noneleft" style="text-align: center;">{text}</div>'
  }))

  $.get('/api/tags.json').done(function (tags) {
    var tagEls = tags
    .sort(function (lhs, rhs) {
      return rhs.count - lhs.count
    })
    .filter(function (tag) {
      return tag.count > 0 
    })
    .map(function (tag) {
      return $('<a>', {
        class: 'tag',
        href: '/tags.html#' + tag.name
      }).html(tag.name + '(' + tag.count + ')')
    })
    $('.tag-list').append(tagEls)
  })
  var links = [{
    icon: 'fa-code-fork',
    url: 'https://github.com/binlinrepo/binlinrepo.github.io',
    target: '_blank'
  }, {
    plugin: 'rss',
    url: 'https://binlinrepo.github.io/feed.xml',
    target: '_blank'
  }, {
    icon: 'fa-envelope',
    background: '#5484d6',
    url: 'mailto:binlin.duan@foxmail.com?subject=关于博客'
  }, {
    plugin: 'weibo',
    url: 'https://weibo.com/p/1005055336529982/home',
    target: '_blank'
  },{
    plugin: 'linkedin',
    url: 'https://linkedin.com/in/斌琳-段-29747b148/',
    target: '_blank'
  }]
  socialShare($('.follow').get(0), links, {size: 'sm'})
})
