# encoding: utf-8

require 'yaml'

Gem::Specification.new do |gemspec|
  root = File.dirname(__FILE__)
  lib_dir = File.join(root,'lib')
  files = if File.directory?('.git')
            `git ls-files`.split($/)
          elsif File.directory?('.hg')
            `hg manifest`.split($/)
          elsif File.directory?('.svn')
            `svn ls -R`.split($/).select { |path| File.file?(path) }
          else
            Dir['{**/}{.*,*}'].select { |path| File.file?(path) }
          end

  filter_files = lambda { |paths|
    case paths
    when Array
      (files & paths)
    when String
      (files & Dir[paths])
    end
  }

  version = {
    :file => 'spidr/version',
    :constant => 'Spidr::VERSION'
  }

  defaults = {
    'name' => File.basename(root),
    'files' => files,
    'executables' => filter_files['bin/*'].map { |path| File.basename(path) },
    'test_files' => filter_files['{test/{**/}*_test.rb,spec/{**/}*_spec.rb}'],
    'extra_doc_files' => filter_files['*.{txt,rdoc,md,markdown,tt,textile}'],
  }

  metadata = defaults.merge(YAML.load_file('gemspec.yml'))

  gemspec.name = metadata.fetch('name',defaults[:name])
  gemspec.version = if metadata['version']
                      metadata['version']
                    else
                      $LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

                      require version[:file]
                      eval(version[:constant])
                    end

  gemspec.summary = metadata.fetch('summary',metadata['description'])
  gemspec.description = metadata.fetch('description',metadata['summary'])

  case metadata['license']
  when Array
    gemspec.licenses = metadata['license']
  when String
    gemspec.license = metadata['license']
  end

  case metadata['authors']
  when Array
    gemspec.authors = metadata['authors']
  when String
    gemspec.author = metadata['authors']
  end

  gemspec.email = metadata['email']
  gemspec.homepage = metadata['homepage']

  case metadata['require_paths']
  when Array
    gemspec.require_paths = metadata['require_paths']
  when String
    gemspec.require_path = metadata['require_paths']
  end

  gemspec.files = filter_files[metadata['files']]

  gemspec.executables = metadata['executables']
  gemspec.extensions = metadata['extensions']

  if Gem::VERSION < '1.7.'
    gemspec.default_executable = gemspec.executables.first
  end

  gemspec.test_files = filter_files[metadata['test_files']]

  unless gemspec.files.include?('.document')
    gemspec.extra_rdoc_files = metadata['extra_doc_files']
  end

  gemspec.post_install_message = metadata['post_install_message']
  gemspec.requirements = metadata['requirements']

  if gemspec.respond_to?(:required_ruby_version=)
    gemspec.required_ruby_version = metadata['required_ruby_version']
  end

  if gemspec.respond_to?(:required_rubygems_version=)
    gemspec.required_rubygems_version = metadata['required_rubygems_version']
  end

  parse_versions = lambda { |versions|
    case versions
    when Array
      versions.map { |v| v.to_s }
    when String
      versions.split(/,\s*/)
    end
  }

  if metadata['dependencies']
    metadata['dependencies'].each do |name,versions|
      gemspec.add_dependency(name,parse_versions[versions])  
    end
  end

  if metadata['runtime_dependencies']
    metadata['runtime_dependencies'].each do |name,versions|
      gemspec.add_runtime_dependency(name,parse_versions[versions])  
    end
  end

  if metadata['development_dependencies']
    metadata['development_dependencies'].each do |name,versions|
      gemspec.add_development_dependency(name,parse_versions[versions])  
    end
  end
end
