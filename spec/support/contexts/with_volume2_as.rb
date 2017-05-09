# Creates volume2 as described, inserts it into the rights and feed
# tables, and sets up descriptive `let` statements.
#
# This context is intended to be called within the integration context.
#
# @param right [Symbol] The right the volume should have, e.g. :pd
# @param access_profile [Symbol] The access_profile, e.g. :open
# @param timestamp [Time] The timestamp of the volume's database entry
RSpec.shared_context "with volume2 as" do |right, access_profile, timestamp|
  let(:rights_schema) do
    Datasets::SchemaBuilder.new(Datasets.config.db_connection)
  end

  let(:volume2) do
    Datasets::Volume.new(
      namespace: "test", id: "002",
      access_profile: access_profile, right: right
    )
  end

  let(:volume2_rights_tuple) do
    {
      namespace: "test", id: "002",
      reason: 1, source: 2,
      attr: rights_schema.attribute_id(right),
      access_profile: rights_schema.access_profile_id(access_profile),
      user: "testuser", time: timestamp
    }
  end

  let(:volume2_feed_tuple) do
    {
      namespace: "test", id: "002",
      zip_size: 10398103, zip_date: timestamp,
      mets_size: 1111, mets_date: Time.at(0),
      lastchecked: timestamp, md5check_ok: nil
    }
  end

  before(:each) do
    feed_table.insert volume2_feed_tuple
    rights_table.insert volume2_rights_tuple
  end
end
