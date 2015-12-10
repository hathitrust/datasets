require 'zip'

Zip::OutputStream.open('exampleout.zip') do |zos|
  zos.put_next_entry('dir/hello.txt')
  zos.puts 'Hello hello hello hello hello hello hello hello hello'

  zos.put_next_entry('dir/hi.txt')
  zos.puts 'Hello again'

  # Use rubyzip or your zip client of choice to verify
  # the contents of exampleout.zip
end

