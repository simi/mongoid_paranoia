# Paranoid Documents for Mongoid 4

There may be times when you don't want documents to actually get deleted from the database, but "flagged" as deleted. mongoid-paranoia provides a Paranoia module to give you just that.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid-paranoia'
```

## Usage

```ruby
class Person
  include Mongoid::Document
  include Mongoid::Paranoia
end

person.delete   # Sets the deleted_at field to the current time, ignoring callbacks.
person.delete!  # Permanently deletes the document, ignoring callbacks.
person.destroy  # Sets the deleted_at field to the current time, firing callbacks.
person.destroy! # Permanently deletes the document, firing callbacks.
person.restore  # Brings the "deleted" document back to life.
```

The documents that have been "flagged" as deleted (soft deleted) can be accessed at any time by calling the deleted class method on the class.

```ruby
Person.deleted # Returns documents that have been "flagged" as deleted.
```

## TODO
- get rid of [monkey_patches.rb](https://github.com/simi/mongoid-paranoia/blob/master/lib/mongoid/paranoia/monkey_patches.rb)
- review persisted? behaviour

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
