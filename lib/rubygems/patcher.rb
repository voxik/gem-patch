require "rbconfig"
require "tmpdir"
require "rubygems/installer"
#require "rubygems/builder"
#require "fileutils"

class Gem::Patcher
  #include Gem::UserInteraction

  def initialize(gemfile, output_dir)
    @gemfile    = gemfile
    @output_dir = output_dir
  end

  # Patch the gem with given patches 
  def patch_with(patches)
    @package = Gem::Package.new @gemfile

    @tmpdir     = Dir.mktmpdir
    @basename   = File.basename(@gemfile, '.gem')
    @target_dir = File.join(@tmpdir, @basename)

    info "Unpacking gem '#{@basename}'..."

    @package.extract_files @target_dir #Dir.pwd

    # Apply all patches
    for p in patches
      info 'Applying patch ' + p
      apply_patch(p)
    end

    # Name of the patched gem
    @patched_gem = @package.spec.file_name

    # New gem file that will be generated
    package = Gem::Package.new @patched_gem
    package.spec = @package.spec

    # Change dir
    @pwd = Dir.pwd
    Dir.chdir @target_dir

    # Build the patched gem
    package.build true

    # Go back to working dir
    Dir.chdir @pwd

    # Move newly generated gem to working directory
    system("mv #{@target_dir}/#{@patched_gem} #{@patched_gem}")
  end

  # Apply a patch
  def apply_patch(patch)

    # Keeping the file path absolute
    patch_path = File.join(File.expand_path(File.dirname(patch)), File.basename(patch))
    info 'Path to the patch to apply: ' + patch_path

    # Applying the patch by calling patch -p0
    if system("cd #{@target_dir};patch -p0 < #{patch_path}")
        info 'Succesfully patched by ' + patch
      else
        info 'Error: Unable to patch with ' + patch
      end
  end

  private

  def info(msg)
    puts msg if Gem.configuration.verbose
  end
end