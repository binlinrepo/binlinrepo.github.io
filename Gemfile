source "https://gems.ruby-china.com/"
#source "https://rubygems.org"
gem "jekyll", "~> 3.8.5"
gem "minima", "~> 2.5"

#gem "github-pages", group: :jekyll_plugins
group :jekyll_plugins do
  	gem "jekyll-feed", "~> 0.12"
	gem 'jekyll-seo-tag', "~> 2.6.1"
	gem 'jekyll-redirect-from',"~> 0.15"
	gem 'jekyll-sitemap', "~> 1.4"
	gem "jekyll-paginate", "~> 1.1"
end

install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :install_if => Gem.win_platform?

