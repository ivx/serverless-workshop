# -*- encoding: utf-8 -*-
# stub: aws-xray-sdk 0.11.2 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-xray-sdk".freeze
  s.version = "0.11.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "2019-07-18"
  s.description = "The AWS X-Ray SDK for Ruby enables Ruby developers to record and emit information from within their applications to the AWS X-Ray service.".freeze
  s.email = "aws-xray-ruby@amazon.com".freeze
  s.homepage = "https://github.com/aws/aws-xray-sdk-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.6".freeze)
  s.rubygems_version = "3.0.4".freeze
  s.summary = "AWS X-Ray SDK for Ruby".freeze

  s.installed_by_version = "3.0.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<aws-sdk-xray>.freeze, ["~> 1.4.0"])
      s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1"])
      s.add_development_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1"])
      s.add_development_dependency(%q<aws-sdk-s3>.freeze, ["~> 1"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<rack>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.15"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
    else
      s.add_dependency(%q<aws-sdk-xray>.freeze, ["~> 1.4.0"])
      s.add_dependency(%q<multi_json>.freeze, ["~> 1"])
      s.add_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1"])
      s.add_dependency(%q<aws-sdk-s3>.freeze, ["~> 1"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.15"])
      s.add_dependency(%q<webmock>.freeze, ["~> 3.0"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<aws-sdk-xray>.freeze, ["~> 1.4.0"])
    s.add_dependency(%q<multi_json>.freeze, ["~> 1"])
    s.add_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1"])
    s.add_dependency(%q<aws-sdk-s3>.freeze, ["~> 1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.15"])
    s.add_dependency(%q<webmock>.freeze, ["~> 3.0"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9"])
  end
end
