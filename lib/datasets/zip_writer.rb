require 'zip'
require 'digest'

# Writes a zip file from a volume source path
# to a destination path.
module Datasets
  class ZipWriter
    # Write the dataset from src_path to the directory at dest_path. Constructs the output
    # zip in memory, writes it to a temporary path, and then moves it into the
    # given dest_path.
    #
    # @param [Pathname] src_path
    # @param [Pathname] dest_path
    # @yield [input_zip, output_zip_stream] optional block for implementation of copying
    # from input Zip::File to a Zip::OutputStream. By default gets all txt files in input zip
    # and copies them to output zip.
    def write(src_path, dest_path, &block)
      tmp_path = dest_path.dirname.join(tmpname)
      stringio = Zip::OutputStream.write_buffer do |output_zip_stream|
        Zip::File.open(src_path.to_s) do |input_zip|
          (block || copy_text).call input_zip, output_zip_stream
        end
      end

      File.open(tmp_path,"w") do |output_zip|
        stringio.rewind
        IO.copy_stream(stringio,output_zip)
      end

      # rename should be atomic since we have guaranteed tmp_path is in the same
      # directory as dest_path
      tmp_path.rename(dest_path)
    ensure
      tmp_path.unlink if tmp_path.exist?
    end

    private

    def tmpname
      t = Time.now.strftime("%Y%m%d")
      "dataset-#{t}-#{$$}-#{rand(0x100000000).to_s(36)}.zip"
    end

    def copy_text
      @copy_text_proc ||= proc do |input_zip, output_zip_stream|
        input_zip.glob('**/*.txt').each do |txt|
          output_zip_stream.put_next_entry(txt.name)
          txt.get_input_stream do |txt_input_stream|
            IO.copy_stream(txt_input_stream, output_zip_stream)
          end
        end
      end
    end
  end
end
