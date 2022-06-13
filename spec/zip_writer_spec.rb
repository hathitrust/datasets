require_relative "./spec_helper"
require "zip_writer"
require "zip"
require "pathname"

module Datasets
  RSpec.describe ZipWriter do
    let(:fixtures_dir) { Pathname.new(File.expand_path(__FILE__)).dirname + "fixtures" }
    let(:src_path) { Pathname.new(fixtures_dir) + "test_volume.zip" }

    def create_output_zip
      Dir.mktmpdir("datasets_test") do |dir|
        dest_path = Pathname.new(dir) + "out.zip"
        ZipWriter.new.write(src_path, dest_path)
        yield(dest_path)
      end
    end

    # pass a block that does awful things to the output zip and/or raises an
    # error. ZipWriter should not leave a broken output zip.
    def expect_no_zip
      Dir.mktmpdir("datasets_test") do |dir|
        dest_path = Pathname.new(dir) + "out.zip"
        begin
          ZipWriter.new.write(src_path, dest_path) do |input_zip, output_zip|
            yield input_zip, output_zip
          end
        rescue
          # don't care if there are weird errors, just need to make sure the temp
          # zip is cleaned up properly
        end
        expect(dest_path).not_to exist
      end
    end

    it "passes a string to Zip::File" do
      # rubzip can have unexpected behavior with things that behave like
      # Strings but aren't due to internal use of is_a?. This test ensures
      # we're following rubyzip's implicit interface contract.
      expect(Zip::File).to receive(:open).with(instance_of(String)).and_yield(double(:input_zip))

      begin
        # don't actually try to put anything in output zip
        Dir.mktmpdir("datasets_test") do |dir|
          ZipWriter.new.write(src_path, Pathname.new(dir) / "whatever.zip") { |_, _| }
        end
      rescue Errno::ENOENT
        # won't actually create an output zip, don't care
      end
    end

    it "creates a file at the specified destination path" do
      create_output_zip do |output|
        expect(output).to exist
      end
    end

    it "creates an openable zip file" do
      create_output_zip do |output|
        expect { Zip::File.open(output.to_s) {} }.to_not raise_error
      end
    end

    it "creates a zip containing all the text files in the source zip" do
      create_output_zip do |output|
        texts = Zip::File.open(output.to_s) do |z|
          z.glob("**/*.txt")
            .map { |entry| File.basename(entry.name) }
        end
        expect(texts).to contain_exactly("00000001.txt", "00000002.txt")
      end
    end

    it "creates a zip without non-text files in the source zip" do
      create_output_zip do |output|
        expect(
          Zip::File.open(output.to_s) do |z|
            z.map { |entry| Pathname.new(entry.name) }
              .reject { |path| path.extname == ".txt" }
          end
        ).to be_empty
      end
    end

    it "creates a zip that has a text file whose content matches the text in the source zip" do
      create_output_zip do |output|
        src_text = Zip::File.open(src_path.to_s) { |z| z.get_input_stream("test_volume/00000002.txt").read }
        dest_text = Zip::File.open(output.to_s) { |z| z.get_input_stream("test_volume/00000002.txt").read }
        expect(src_text).to eq(dest_text)
      end
    end

    it "when copying process raises Zip::Error, does not leave a broken zip file" do
      expect_no_zip do |_, _|
        raise Zip::Error
      end
    end

    it "when copying process raises Zip::Error in the middle of creating a file in the output zip, does not leave a broken zip file" do
      expect_no_zip do |_, output_zip_stream|
        output_zip_stream.put_next_entry("foo")
        # write some junk, don't close the output stream, raise an error...
        # will provoke a warning:
        #   zlib(finalizer): the stream was freed prematurely.
        output_zip_stream.write("garbage" * 200)
        raise Zip::Error
      end
    end
  end
end
