# Effects

## Example

```ruby
process = Effects::Process.new(steps: [:A, :B, :C]) do |y|
  puts "Process entered"
  y.yield(:A)
  puts "Process step completed: :A"
  y.yield(:B)
  puts "Process step completed: :B"
  y.yield(:C)
  puts "Process step completed: :C"
  puts "Terminating process"
end

puts "Hello"
process.(:A)
puts "World"
process.(:B)
puts "It's me!"
process.finish

# or

process.call do
  puts "Hello"
  process.(:A)
  puts "World"
  process.(:B)
  puts "It's me!"
end
```

## Running Tests

Sync Gemfile.lock versions with application and install dependencies

```
bin/setup
```

run the tests

```
bundle exec rake
```
