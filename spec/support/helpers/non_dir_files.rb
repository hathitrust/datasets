# Get the relative paths of every non-directory
# file under the given path, which should be a directory.
# @param path [Pathname] Should be a directory
# @return [Array<Pathname>]
def non_dir_files(path)
  `find -L #{path}`
    .split
    .map{|f| Pathname.new(f) }
    .reject{|f| f.directory? }
    .map{|f| f.relative_path_from(path) }
end
