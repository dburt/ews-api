# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ews-api}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jrun"]
  s.date = %q{2009-12-17}
  s.description = %q{Exchange Web Services API. It doesn't use soap4r.}
  s.email = %q{jeremy.burks@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "ews-api.gemspec",
     "lib/ews-api.rb",
     "lib/ews/attachment.rb",
     "lib/ews/error.rb",
     "lib/ews/folder.rb",
     "lib/ews/message.rb",
     "lib/ews/model.rb",
     "lib/ews/parser.rb",
     "lib/ews/service.rb",
     "spec/ews/attachment_spec.rb",
     "spec/ews/folder_spec.rb",
     "spec/ews/message_spec.rb",
     "spec/ews/model_spec.rb",
     "spec/ews/parser_spec.rb",
     "spec/ews/service_spec.rb",
     "spec/fixtures/find_folder.xml",
     "spec/fixtures/find_item.xml",
     "spec/fixtures/find_item_all_properties.xml",
     "spec/fixtures/get_attachment.xml",
     "spec/fixtures/get_folder.xml",
     "spec/fixtures/get_item_all_properties.xml",
     "spec/fixtures/get_item_default.xml",
     "spec/fixtures/get_item_id_only.xml",
     "spec/fixtures/get_item_no_attachments.xml",
     "spec/fixtures/get_item_with_error.xml",
     "spec/integration.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jrun/ews-api}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Exchange Web Services API}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/integration.rb",
     "spec/ews/parser_spec.rb",
     "spec/ews/message_spec.rb",
     "spec/ews/attachment_spec.rb",
     "spec/ews/folder_spec.rb",
     "spec/ews/service_spec.rb",
     "spec/ews/model_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 0"])
      s.add_runtime_dependency(%q<rubyntlm>, [">= 0"])
      s.add_runtime_dependency(%q<handsoap>, ["= 1.1.4"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<httpclient>, [">= 0"])
      s.add_dependency(%q<rubyntlm>, [">= 0"])
      s.add_dependency(%q<handsoap>, ["= 1.1.4"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 0"])
    s.add_dependency(%q<rubyntlm>, [">= 0"])
    s.add_dependency(%q<handsoap>, ["= 1.1.4"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

