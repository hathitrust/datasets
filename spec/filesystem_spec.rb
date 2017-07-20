require_relative "./spec_helper"
require "filesystem"
require "pathname"
require "fileutils"

module Datasets
  RSpec.describe Filesystem do
    let(:fs) { described_class.new }

    describe "stat methods" do
      describe "#modify_time" do
        it "returns mtime as a Time object" do
          expect(fs.modify_time(Pathname.new("/tmp"))).to be < Time.now
        end
      end
      describe "#exists?" do
        it "is true when the file exists" do
          expect(fs.exists?(Pathname.new("/etc/passwd"))).to be true
        end
        it "is true when the dir exists" do
          expect(fs.exists?(Pathname.new("/tmp"))).to be true
        end
        it "is false when the file/dir is not present" do
          expect(fs.exists?(Pathname.new("/something/that/does/not/exist/1283719371")))
            .to be false
        end
      end
    end

    describe "creation/deletion methods" do
      TMPPATH = Pathname.new(File.join(File.dirname(__FILE__), "tmp"))
      before(:each) do
        FileUtils.mkpath TMPPATH
        FileUtils.rm_rf("#{TMPPATH}/.", secure: true)
      end
      after(:all) { FileUtils.remove_entry_secure TMPPATH }

      describe "#read" do
        let(:file) { TMPPATH + "somefile.txt" }
        let(:contents) { "some\ncontents\n\n\n\nmore"}
        it "returns the contents of a file" do
          File.write(file, contents)
          expect(fs.read(file)).to eql(contents)
        end
      end

      describe "#write" do
        let(:path) { TMPPATH + "somefile.txt" }
        let(:contents) { "some\ncontents\n\n\n\nmore"}
        it "writes a file" do
          fs.write(path, contents)
          expect(File.read(path)).to eql(contents)
        end
      end

      describe "#children" do
        let(:files) { [TMPPATH + "one_file.txt", TMPPATH + ".hidden.yml"] }
        let(:dirs) { [TMPPATH + "some_dir", TMPPATH + ".hidden_dir"] }
        before(:each) do
          files.each {|f| File.write(f, "dummy_contents") }
          dirs.each {|d| FileUtils.mkpath d}
        end
        it "returns the entries in the dir as pathnames" do
          expect(fs.children(TMPPATH)).to match_array( (files + dirs))
        end
      end

      describe "#ln_s" do
        let(:src_file_path) { TMPPATH + "src.txt" }
        let(:src_dir_path) { TMPPATH + "src_dir" }
        let(:dest_path) { TMPPATH + "dest" }

        it "creates a symlink dest to a src file" do
          File.write(src_file_path, "contents")
          fs.ln_s(src_file_path, dest_path)
          expect(dest_path.symlink?).to be true
          expect(File.read(dest_path)).to eql("contents")
        end
        it "creates a symlink dest to a src dir" do
          FileUtils.mkdir src_dir_path
          File.write(src_dir_path + "inside.txt", "contents")
          fs.ln_s(src_dir_path, dest_path)
          expect(dest_path.symlink?).to be true
          expect(File.read(dest_path + "inside.txt")).to eql("contents")
        end
        it "is idempotent" do
          File.write(src_file_path, "contents")
          expect {
            fs.ln_s(src_file_path, dest_path)
            fs.ln_s(src_file_path, dest_path)
          }.to_not raise_error
        end
        it "is idempotent if src does not exist" do
          expect {
            fs.ln_s(src_file_path, dest_path)
            fs.ln_s(src_file_path, dest_path)
          }.to_not raise_error
        end
        it "is successful if dest is already a file" do
          File.write(src_file_path, "contents")
          File.write(dest_path, "other contents")
          expect{
            fs.ln_s(src_file_path, dest_path)
          }.to_not raise_error
        end
        it "creates a symlink when src does not exist" do
          fs.ln_s(src_file_path, dest_path)
          expect(dest_path.symlink?).to be true
          File.write(src_file_path, "contents")
          expect(File.read(dest_path)).to eql("contents")
        end
        it "returns true when it creates a symlink" do
          expect(fs.ln_s(src_file_path, dest_path)).to be true
        end
        it "returns false when destination already exists" do
          fs.ln_s(src_file_path, dest_path)
          expect(fs.ln_s(src_file_path, dest_path)).to be false
        end
      end

      describe "#mkdir_p" do
        let(:a_dir) { TMPPATH + "a" }
        let(:ab_dir) { a_dir + "b" }
        let(:abc_dir) { ab_dir + "c" }
        it "creates a directory tree" do
          fs.mkdir_p abc_dir
          expect(a_dir.directory?).to be true
          expect(ab_dir.directory?).to be true
          expect(abc_dir.directory?).to be true
        end
        it "is idempotent" do
          expect {
            fs.mkdir_p abc_dir
            fs.mkdir_p abc_dir
          }.to_not raise_error
        end
      end
      describe "#remove" do
        let(:file_path) { TMPPATH + "src.txt" }
        let(:dir_path) { TMPPATH + "src_dir" }
        it "removes a file" do
          File.write(file_path, "contents")
          fs.remove(file_path)
          expect(file_path.exist?).to be false
        end
        it "removes an empty directory" do
          FileUtils.mkdir dir_path
          fs.remove(dir_path)
          expect(dir_path.exist?).to be false
        end
        it "removes a directory (recursively)" do
          FileUtils.mkdir dir_path
          File.write(dir_path + ".inside.txt", "contents")
          fs.remove(dir_path)
          expect(dir_path.exist?).to be false
        end
        it "is idempotent" do
          expect{
            fs.remove(file_path)
          }.to_not raise_error
        end
        it "returns true when something was removed" do
          File.write(file_path, "contents")
          expect(fs.remove(file_path)).to be true
        end
        it "returns false when nothing was removed" do
          expect(fs.remove(file_path)).to be false
        end
      end
      describe "#rm_empty_tree" do
        let(:a_dir) { TMPPATH + "a" }
        let(:ab_dir) { a_dir + "b" }
        let(:abc_dir) { ab_dir + "c" }
        it "removes empty directories starting at dest" do
          FileUtils.mkdir_p abc_dir
          fs.rm_empty_tree abc_dir
          expect(abc_dir.exist?).to be false
          expect(ab_dir.exist?).to be false
          expect(a_dir.exist?).to be false
        end
        it "does nothing if the directory has content" do
          FileUtils.mkdir_p abc_dir
          inside_file_path = abc_dir + "inside.txt"
          File.write(inside_file_path, "contents")
          fs.rm_empty_tree abc_dir
          expect(abc_dir.exist?).to be true
          expect(inside_file_path.exist?).to be true
        end
        it "does not remove parent directories with content" do
          FileUtils.mkdir_p abc_dir
          inside_file_path = a_dir + "inside.txt"
          File.write(inside_file_path, "contents")
          fs.rm_empty_tree abc_dir
          expect(abc_dir.exist?).to be false
          expect(ab_dir.exist?).to be false
          expect(a_dir.exist?).to be true
          expect(inside_file_path.exist?).to be true
        end
        it "considers hidden files to be content" do
          FileUtils.mkdir_p abc_dir
          inside_file_path = abc_dir + ".inside.txt"
          File.write(inside_file_path, "contents")
          fs.rm_empty_tree abc_dir
          expect(abc_dir.exist?).to be true
          expect(inside_file_path.exist?).to be true
        end
        it "is idempotent" do
          expect{
            fs.rm_empty_tree abc_dir
          }.to_not raise_error
        end
        it "raises an ArgumentError when given a filepath" do
          expect{
            fs.rm_empty_tree Pathname.new("/etc/passwd")
          }.to raise_error(ArgumentError)
        end
      end


    end

  end
end
