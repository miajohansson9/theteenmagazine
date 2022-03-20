# -*- encoding: utf-8 -*-
# stub: sprockets_better_errors 0.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "sprockets_better_errors".freeze
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Richard Schneeman".freeze]
  s.date = "2013-12-06"
  s.description = " Raise now so you don't pay later ".freeze
  s.email = ["richard.schneeman+rubygems@gmail.com".freeze]
  s.homepage = "https://github.com/schneems/sprockets_better_errors".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\nTo enable sprockets_better_errors\nadd this line to your `config/environments/development.rb:\n  config.assets.raise_production_errors = true\n\n".freeze
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Better sprockets errors in development so you'll know if things work before you push to production".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<sprockets-rails>.freeze, [">= 1.0.0"])
    s.add_development_dependency(%q<capybara>.freeze, [">= 0.4.0"])
    s.add_development_dependency(%q<launchy>.freeze, ["~> 2.1.0"])
    s.add_development_dependency(%q<poltergeist>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<sprockets-rails>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<capybara>.freeze, [">= 0.4.0"])
    s.add_dependency(%q<launchy>.freeze, ["~> 2.1.0"])
    s.add_dependency(%q<poltergeist>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
