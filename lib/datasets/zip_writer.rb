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
    tmp_path = dest_path.dirname.join(Dir::Tmpname.make_tmpname('dataset', '.zip'))
    Zip::File.open(src_path) do |input_zip|
      Zip::File.open(tmp_path, Zip::File::CREATE) do |output_zip|
        (block || copy_text).call input_zip, output_zip
      end
    end

    # rename should be atomic since we have guaranteed tmp_path is in the same
    # directory as dest_path
    tmp_path.rename(dest_path)
  ensure
    tmp_path.unlink if tmp_path.exist?
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
