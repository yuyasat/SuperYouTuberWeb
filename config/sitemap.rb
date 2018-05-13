# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://super-youtuber.com/"

SitemapGenerator::Sitemap.create do
  add about_path, priority: 0.3, changefreq: 'monthly'
  add term_path, priority: 0.3, changefreq: 'monthly'
  add privacy_policy_path, priority: 0.3, changefreq: 'monthly'
  add sitemap_path, priority: 0.3, changefreq: 'daily'

  Category.root.select { |c| !c.special_root? }.each do |cat1|
    add category_path(cat1), priority: 0.7, changefreq: 'daily'
  end
  Category.secondary.decorate.select { |c| !c.mappable? && !c.music? }.each do |cat2|
    add cat2.path, priority: 0.5, changefreq: 'daily'
  end
  Category.tertiary.decorate.select { |c| !c.mappable? && !c.music? }.each do |cat3|
    add cat3.path, priority: 0.5, changefreq: 'daily'
  end

  add music_index_path, priority: 0.5, changefreq: 'daily'

  # See also CategoryController#index
  music_category = Category.find_by(id: SpecialCategory.where(url: 'music').select('category_id'))
  category_movies = Movie.grouped_by_categories(num: 10, target_category: music_category)
  Category.where(id: category_movies.keys.map(&:id)).decorate.each do |cat2|
    add cat2.music_path, priority: 0.5, changefreq: 'daily'
  end
  Category.where(id: category_movies.keys.map(&:id)).flat_map { |c|
    c.children.have_movies
  }.map(&:decorate).each do |cat3|
    add cat3.music_path, priority: 0.5, changefreq: 'daily'
  end


  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
