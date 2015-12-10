require 'sequel'
DB = Sequel.connect(:adapter => 'mysql2', :database=>'ht', :user => 'rrotter', :password => 'somthingness1', :host => 'mysql-sdr')

headings = [:namespace,:id,:rec,:pubdate,:lang,:gov]
rows = []
ARGF.each do |line|
  htid,access,rights,rec,enum_cron,src,src_rec,oclc,isbn,issn,lccn,title,imprint,reason,update,gov,pubdate,pub_place,lang,bib_fmt = line.split("\t")

  namespace,id = htid.split('.',2)
  rows << [namespace,id,rec,pubdate,lang,gov]

  if rows.length >= 2000
    DB[:hathi_file].on_duplicate_key_update.import(headings,rows)
    puts rows[0].join(',')
    rows = []
  end
end

__END__

    my $htid = $fields[0];
    my ($namespace,$id) = split(/\./,$htid,2);
    my $pubdate = $fields[16];
    my $lang008 = $fields[18];

