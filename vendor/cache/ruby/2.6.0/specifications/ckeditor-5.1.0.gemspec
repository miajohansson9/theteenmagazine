# -*- encoding: utf-8 -*-
# stub: ckeditor 5.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ckeditor".freeze
  s.version = "5.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Igor Galeta".freeze]
  s.date = "2020-03-06"
  s.description = "CKEditor is a WYSIWYG editor to be used inside web pages".freeze
  s.email = "galeta.igor@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "https://github.com/galetahub/ckeditor".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Rails gem for easy integration ckeditor in your application".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<orm_adapter>.freeze, ["~> 0.5.0"])
  else
    s.add_dependency(%q<orm_adapter>.freeze, ["~> 0.5.0"])
  end
end
