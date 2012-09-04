require "rubygems/command"

class Gem::Commands::PatchCommand < Gem::Command
  def initialize
    super "patch", "Patches the gem with the given patches and generates patched gem.",
      :output => Dir.pwd
  end

  def arguments
    "GEMFILE       path to the gem file to patch
     PATCHES       list of patches to apply"
  end

  def usage
    "#{program_name} GEMFILE PATCHES"
  end

  def execute
    gemfile = options[:args].shift # Gem file is the first argument
    patches = options[:args]
    
    # No gem
    unless gemfile
      raise Gem::CommandLineError,
        "Please specify a gem file on the command line (e.g. #{program_name} foo-0.1.0.gem PATCHES)"
    end

    # No patches
    if patches.size == 0
      raise Gem::CommandLineError,
        "Please specify patches to apply (e.g. #{program_name} foo-0.1.0.gem foo.patch bar.patch ...)"
    end

    require "rubygems/patcher"

    # For testing only
    #puts 'Output directory: ' + options[:output]
    #puts 'Gemfile: ' + gemfile
    #puts 'Patches: ' + patches.join(",")

    # Creates patcher
    patcher = Gem::Patcher.new(gemfile, options[:output])

    # Patch
    patcher.patch_with(patches)
  end
end