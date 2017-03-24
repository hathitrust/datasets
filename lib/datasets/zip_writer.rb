require 'zip'

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
  def write(src_path, dest_path)
    # open the source and destination zips

    temp_zip = Tempfile.open(['dataset', '.zip'], File.dirname(dest_path))

    begin
      # initialize zip file - required since we opened the file w/ Tempfile
      Zip::OutputStream.open(temp_zip) { |zos| }

      Zip::File.open(src_path) do |input_zip|
        Zip::File.open(temp_zip.path, Zip::File::CREATE) do |output_zip|
          if block_given?
            yield input_zip, output_zip
          else
            copy_text(input_zip, output_zip)
          end
        end
      end

      # rename should be atomic; cross-partition move with FileUtils.mv may
      # not be
      File.rename(temp_zip, dest_path)
      #    rescue Zip::Error
      # TODO: handle and propagate error
    ensure
      temp_zip.close
      temp_zip.unlink
    end
  end

  private

  def copy_text(input_zip, output_zip)
    input_zip.glob('**/*.txt').each do |txt|
      txt.get_input_stream do |txt_input_stream|
        output_zip.get_output_stream(txt.name) do |txt_output_stream|
          IO.copy_stream(txt_input_stream, txt_output_stream)
        end
      end
    end
  end
end
