# write some data with sequel
# use config file
# write it from thread pool, connection pool

require 'sequel'
require 'concurrent'

if PLATFORM=='java'
  DB = Sequel.connect('jdbc:mysql://mysql-htdev:3306/rrotter_ht?user=rrotter&password=somthingness1', :max_connections=>10)
else
  DB = Sequel.connect('mysql2://rrotter:somthingness1@mysql-htdev:3306/rrotter_ht')
end

$write_queue = Concurrent::Map.new
$errors = Concurrent::Map.new

def work(item) {
  
}

def write {
  $write_queue
  $errors
}

worker_pool = Concurrent::ThreadPoolExecutor.new(
   min_threads: 50,
   max_threads: 50,
   max_queue: 100,
   fallback_policy: :caller_runs
)

write_queue = Concurrent::Map.new
errors = Concurrent::Map.new



(1..1000).each do |i|
  worker_pool.post do
    begin
      stime = rand 5
      if stime > 3
        raise "too much sleep"
      end
      # sleep stime
      # puts "Hello #{i}"
      # DB[:thread_test].insert(:thread => i, :data => "stime is #{stime}")
      write_queue[i] = "stime is #{stime}"
    rescue Exception => e
      errors[i] = e
    end
  end
end

worker_pool.shutdown
writer.shutdown


puts "success in #{write_queue.size} cases"
puts "Errors: #{errors.size}"
# require 'pry'
# binding.pry

# table.insert(:thread => 0, :data => "foobar")
