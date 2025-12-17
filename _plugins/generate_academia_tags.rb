# _plugins/generate_academia_tags.rb
module Jekyll
  class AcademiaTagsGenerator < Generator
    safe true

    def generate(site)
      # Obtener solo los documentos de la colección academia
      academia_docs = site.collections['academia'].docs

      # Crear un hash para agrupar items por tag
      tag_map = Hash.new { |hash, key| hash[key] = [] }

      academia_docs.each do |doc|
        next unless doc.data['tags']
        Array(doc.data['tags']).each do |tag|
          tag_map[tag] << doc
        end
      end

      # Generar una página por cada tag de academia
      tag_map.each do |tag, items|
        site.pages << AcademiaTagPage.new(site, site.source, tag, items)
      end
    end
  end

  # Clase que representa la página de tag de academia
  class AcademiaTagPage < Page
    def initialize(site, base, tag, items)
      @site = site
      @base = base
      # Carpeta: /tags/<tag>/
      safe_tag = tag.downcase.strip.gsub(/[^a-z0-9\-]/, '-')
      @dir = File.join('tags', safe_tag)      
      @name = 'index.html'

      self.process(@name)
      # Usamos tu layout tag.html
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')

      self.data['title'] = tag
      self.data['tag']   = tag
      self.data['posts'] = items
      self.data['collection'] = 'academia_tags'
    end
  end
end
