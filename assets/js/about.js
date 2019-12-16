document.addEventListener('DOMContentLoaded', function () {
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
