# Paranoid Documents for Mongoid 4 [![Build Status](https://travis-ci.org/simi/mongoid-paranoia.png?branch=master)](https://travis-ci.org/simi/mongoid-paranoia)

There may be times when you don't want documents to actually get deleted from the database, but "flagged" as deleted. mongoid-paranoia provides a Paranoia module to give you just that.

**Old API** from Mongoid 3.0 is extracted in [3.0.0-stable branch](https://github.com/simi/mongoid-paranoia/tree/3.0.0-stable) and **doesn't work** with **Mongoid 4** anymore.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid-paranoia'
```

## Changes in 4.0
### [Uniqueness validator is not overriding default one](https://github.com/simi/mongoid-paranoia/commit/ce69dfeeb3f625535749ac919f2f643d47f3cdf4)
This will be changed soon - https://github.com/simi/mongoid-paranoia/issues/5.

#### Old syntax:
```ruby
validates_uniqueness_of :title
validates :title, :uniqueness => true
```

#### New syntax:
```ruby
validates :title, :uniqueness_including_deleted => true
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

You can also access all documents (both deleted and non-deleted) at any time by using the `unscoped` class method:

```ruby
Person.unscoped.all # Returns all documents, both deleted and non-deleted
```

## TODO
- get rid of [monkey_patches.rb](https://github.com/simi/mongoid-paranoia/blob/master/lib/mongoid/paranoia/monkey_patches.rb)
- [review persisted? behaviour](https://github.com/simi/mongoid-paranoia/issues/2)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
