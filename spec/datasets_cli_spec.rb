# frozen_string_literal: true
require "spec_helper"
require "datasets_cli"
require "fileutils"

module Datasets
  RSpec.describe CLI, integration: true do
    def run_cli
      described_class.start(["all"])
    end

    INTEGRATION_HOME = File.join(File.dirname(__FILE__),"integration")
    DATASET_ROOT = File.join(INTEGRATION_HOME,"datasets")
    REPO_ROOT = File.join(INTEGRATION_HOME,"repo")
    DATASETS = [%w(ht_text_pd
                  ht_text_pd_open_access
                  ht_text_pd_world
                  ht_text_pd_world_open_access)].freeze

    OLD_TIMESTAMP=Time.new('1970-01-01T00:00:00Z');
    NEW_TIMESTAMP=Time.new('2017-04-01T00:00:00Z');

    INTEGRATION_DB_PATH=File.join(INTEGRATION_HOME,"demo.db")

    # should fully reset and re-seed for each test?
    def reset_database(db)
      db.run("delete from feed_audit")
      db.run("delete from rights_current")
    end

    def reset_repository_timestamps(repo_path)
      pairtree_prefix = File.join(repo_path,"obj/test/pairtree_root/00")

      old_vol_file = File.join(pairtree_prefix,"1","001","001.zip")
      FileUtils.touch(old_vol_file,mtime: OLD_TIMESTAMP)

      new_vol_file = File.join(pairtree_prefix,"2","002","002.zip")
      FileUtils.touch(new_vol_file,mtime: NEW_TIMESTAMP)
    end

    def add_test_data(db)
      db[:feed_audit].insert(namespace: "test",
                             id: "001",
                             lastchecked: NEW_TIMESTAMP,
                             zip_date: OLD_TIMESTAMP)

      db[:feed_audit].insert(namespace: "test",
                             id: "002",
                             lastchecked: NEW_TIMESTAMP,
                             zip_date: NEW_TIMESTAMP)

      # pd/bib, google-digitized
      db[:rights_current].insert(namespace: "test",
                                 id: "001",
                                 attr: "1",
                                 reason: "1",
                                 source: "1",
                                 access_profile: "2",
                                 user: "testuser",
                                 time: "1970-01-01T00:00:00Z")

      # ic/bib, internet archive digitized
      db[:rights_current].insert(namespace: "test",
                                 id: "002",
                                 attr: "2",
                                 reason: "1",
                                 source: "2",
                                 access_profile: "1",
                                 user: "testuser",
                                 time: "2017-04-03T00:00:00Z")


    end

    def reset_dataset_output_paths(root_path,dataset)
      FileUtils.rmtree(root_path)
      dataset.each do |dataset|
        FileUtils.mkdir_p(File.join(root_path, dataset, "obj"))
      end
    end
    
    def expect_correct_zip_file(subset, path_in_subset)
      zipfile = File.join(DATASET_ROOT,subset,path_in_subset)
      files = Zip::File.open(zipfile) do |z|
        z.map { |entry| File.basename(entry.name) }
      end
      expect(files).to contain_exactly('00000001.txt', '00000002.txt')
    end

    let(:database) { Sequel.connect(adapter: 'sqlite', 
                                    database: INTEGRATION_DB_PATH) }

    before(:each) do
      Resque.inline = true
      reset_database(database)
      add_test_data(database)
      reset_repository_timestamps(REPO_ROOT)
      reset_dataset_output_paths(DATASET_ROOT,DATASETS)
    end

    after(:each) do 
      reset_database(database)
      reset_dataset_output_paths(DATASET_ROOT,DATASETS)
    end


    it "creates zips containing the expected files" do
      run_cli

      pairtree_prefix = File.join("obj/test/pairtree_root/00")
      old_vol_file = File.join(pairtree_prefix,"1","001","001.zip")
      new_vol_file = File.join(pairtree_prefix,"2","002","002.zip")

      # volume one should be a valid zip with the right files
      expect_correct_zip_file("ht_text",old_vol_file)
      expect_correct_zip_file("ht_text",new_vol_file)
    end

    it "logs creates"

    context "with volumes in the dataset" do
      # put zips in dataset for both vols

      it "updates an existing volume" do
        # set timestamp on one zip to be old
        run_cli
        skip
        # old zip should be updated
        # other volume should be untouched
        # both should be logged
      end

      it "removes a volume that has updated rights" do
        # put zips in dataset for both vols
        # update rights for one to nobody/del
        run_cli
        skip
        # nobody/del volume should be gone
        # other volume should be untouched
        # delete should be logged
      end

      context "with recent last run date" do
        it "updates the out-of-date volume" do
          # set timestamp on one zip to be old
          run_cli
          skip
          # old zip should be updated
          # other volume should be untouched
          # only old one should be logged
        end
      end
    end
  end
end
