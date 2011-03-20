require 'bundler'
Bundler::GemHelper.install_tasks

task :default => 'spec'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "-c -f d"
end
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rspec_opts = "-c -f d"
  t.rcov = true
  t.rcov_opts = ["--exclude", "spec,gems/,rubygems/"]
end

require 'yard'
YARD::Rake::YardocTask.new(:doc) do |t|
  version = Beerxml::VERSION
  t.options = ["--title", "beerxml #{version}", "--files", "LICENSE"]
end

desc "Parse the XML version of the BJCP style guide"
# available at http://www.bjcp.org/stylecenter.php
# This creates Beerxml::Style objects.
# These are then dumped as a beerxml-formatted <STYLES>...</STYLES> tag.
#
# If you just want to use the styles, there's no need to run this rake task
# since they're already included in the library.
# Just call Beerxml::Style.predefined(:bjcp)
#
# Important: BJCP does not currently allow hosting of the guidelines. This
# means that we can't import the tasting notes, descriptions, etc., into the
# app. I've spoken with BJCP to clarify exactly what this means, and it means
# we can import the category information and basic stats like gravities, IBUs,
# etc. But none of the descriptive text fields.
#
# PLEASE do not import the descriptive data into your applications without
# explicit permission from BJCP, they've worked hard on these guides and let's
# not abuse their trust.
task :parse_styleguide, :file_name do |t, args|
  file_name = args.file_name || "data/local/styleguide2008.xml"
  require 'open-uri'
  require 'beerxml'
  styles = []

  read_minmax = proc do |node, style, prefix|
    style.send("#{prefix}_min=", (node>'low').text)
    style.send("#{prefix}_max=", (node>'high').text)
  end

  xml = Nokogiri::XML(open(file_name))
  (xml.root>'class').each do |class_node|
    class_name = class_node['type']

    (class_node>'category').each do |category_node|
      category_name = (category_node>'name').first.text
      category_number = category_node['id']
      style_type = case class_name
      when 'beer'
        if category_name =~ /lager/i
          'Lager'
        else
          'Ale'
        end
      else
        class_name.capitalize
      end

      (category_node>'subcategory').each do |node|
        # the actual style records are here
        style = Beerxml::Style.new(:category => category_name,
                                   :category_number => category_number,
                                   :style_guide => 'BJCP')
        style.name = (node>'name').first.text
        style.style_letter = node['id'][1..-1]
        style.type = style_type
        read_minmax.call((node>'stats'>'og'), style, 'og')
        read_minmax.call((node>'stats'>'fg'), style, 'fg')
        read_minmax.call((node>'stats'>'ibu'), style, 'ibu')
        read_minmax.call((node>'stats'>'srm'), style, 'color')
        read_minmax.call((node>'stats'>'abv'), style, 'abv')

        styles << style
      end
    end
  end
  puts Beerxml::Style.to_beerxml_collection(styles).to_s
end
