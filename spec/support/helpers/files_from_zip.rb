# Get the relative paths of each file in the zip.
# @param zipfile [Pathname]
# @return [Array<Pathname>]
def files_from_zip(zipfile)
  Zip::File.open(zipfile) do |z|
    z.map { |entry| Pathname.new(entry.name) }
  end
end
