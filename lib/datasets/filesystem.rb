require "fileutils"

# We wrap the filesystem for easy mocking,
# and to be clear about which methods we need.
module Datasets
  class Filesystem

    # @param [Pathname] dir
    # @return [Array<Pathname>]
    def children(dir)
      dir.children
    end

    # @param [Pathname] path
    # @return [Time]
    def modify_time(path)
      path.mtime
    end

    # @param [Pathname] path
    # @return [Boolean]
    def exists?(path)
      path.exist?
    end

    # @param [Pathname] path
    # @return [Boolean]
    def symlink?(path)
      path.symlink?
    end

    # Create a symlink at #dest_path to #src_path.
    # If the file already exists, whether it is a
    # link or a normal file, we return success.
    # @param [Pathname] src_path
    # @param [Pathname] dest_path
    # @return [Boolean] true if link was created; false otherwise.
    def ln_s(src_path, dest_path)
      unless exists?(dest_path) or symlink?(dest_path)
        dest_path.make_symlink src_path
        true
      else
        false
      end
    end

    # Create a directory and all intermediate
    # directories. Idempotent.
    # @param [Pathname] path
    def mkdir_p(path)
      path.mkpath
    end

    # Read a file, returning a string.
    # @param [Pathname] path
    # @return [String]
    def read(path)
      File.read(path)
    end

    # rm -rf #path. Idempotent.
    #
    # @return [Boolean] true if something changed; false otherwise.
    # @param [Pathname] path
    def remove(path)
      if exists?(path)
        FileUtils.remove_entry_secure path
        true
      else
        false
      end
    end

    # Remove the directory at #path, then recursively
    # remove each empty parent directory.
    # Idempotent.
    # @param [Pathname] path
    def rm_empty_tree(path)
      raise ArgumentError, "path cannot be a non-directory file" if path.file?
      FileUtils.rmdir path, parents: true
    end

    # Write contents to a file
    # @param [Pathname] path
    # @param [String] contents
    def write(path, contents)
      File.write(path, contents)
    end

  end
end
