## Page command ########

# Use KSS for awesome styleguide support
require "kss"

def site_files
  @site_files ||= (['/index.html'] + Dir['source/styleguide/*html.erb']).map do |f|
    f.gsub(%r{^source}, "").gsub(%r{\.erb}, "")
  end
end

site_files.each do |file|

  page file do
    @styleguide = Kss::Parser.new('source/css')
  end
end

activate :livereload

## Helpers #############

# Methods defined in the helpers block are available in templates
helpers do
  # KSS: Generates a styleguide block. A little bit evil with @_out_buf, but
  # if you're using something like Rails, you can write a much cleaner helper
  # very easily.
  def styleguide_block(section, &block)
    @section = @styleguide.section(section)
    @example_html = kss_capture{ block.call }
    @_out_buf << partial('styleguide/block')
  end

  # KSS: Captures the result of a block within an erb template without spitting
  # it to the output buffer.
  def kss_capture(&block)
    out, @_out_buf = @_out_buf, ""
    yield
    @_out_buf
  ensure
    @_out_buf = out
  end

  class MyDocument; include DocumentMapper::Document; end

  def nav
    content_tag(:ul) do
      (%w(source/index.html.erb) + Dir['source/styleguide/*html.erb']).map do |path|
        nav_item(page_title(path), normalize_path(path))
      end.join
    end
  end

  def nav_item(title, page_name)
    content_tag(:li, link_to(title, page_name))
  end

  def normalize_path(path)
    path.gsub(%r{^source}, "").gsub(%r{\.erb}, "")
  end

  def page_title(page_path)
    doc = MyDocument.from_file(page_path)
    doc.title || normalize_path(page_path)
  end

  def clean_up_path(path)
    path.gsub(%r{.*/}, "")
  end
end

set :css_dir, 'css'
set :js_dir, 'js'
set :images_dir, 'img'

## Build-specific configuration #########

configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :cache_buster

  # Use relative URLs
  # activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
