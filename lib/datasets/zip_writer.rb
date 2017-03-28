require 'zip'
require 'digest'

# Writes a zip file from a volume source path
# to a destination path.
class ZipWriter
  # Write the dataset from src_path to
  # the directory at dest_path.
  # @param [Pathname] src_path
  # @param [Pathname] dest_path
  # @yield [input_zip, output_zip] optional block for implementation of copying
  # from input zip to output zip. By default gets all txt files in input zip
  # and copies them to output zip.
  def write(src_path, dest_path, &block)
    Tempfile.open(['dataset', '.zip'], dest_path.dirname) do |temp_zip|
      Zip::File.open(src_path) do |input_zip|
        Zip::File.open(temp_zip.path, Zip::File::CREATE) do |output_zip|
          (block || copy_text).call input_zip, output_zip
        end
      end

      atomic_cp(temp_zip, dest_path)
    end
  end

  class ChecksumMismatchError < IOError; end

  def atomic_cp(src_path, dest_path)
    src_checksum = Digest::MD5.file src_path
    FileUtils.cp src_path, dest_path
    dest_checksum = Digest::MD5.file dest_path
    raise ChecksumMismatchError unless src_checksum == dest_checksum
  end


  private

  def copy_text
    @copy_text_proc ||= proc do |input_zip, output_zip|
      input_zip.glob('**/*.txt').each do |txt|
        txt.get_input_stream do |txt_input_stream|
          output_zip.get_output_stream(txt.name) do |txt_output_stream|
            IO.copy_stream(txt_input_stream, txt_output_stream)
          end
        end
      end
    end
  end

end
