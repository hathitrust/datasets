
# We wrap the filesystem for easy mocking,
# and to be clear about which methods we need.
class Filesystem
  def exists?(path); end
  def mkdir_p(path); end
  def cp(src_path, dest_path); end
  def remove_entry_secure(path); end
end