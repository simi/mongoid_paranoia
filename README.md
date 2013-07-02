# Paranoid Documents for Mongoid 4 [![Build Status](https://travis-ci.org/simi/mongoid-paranoia.png?branch=master)](https://travis-ci.org/simi/mongoid-paranoia)

There may be times when you don't want documents to actually get deleted from the database, but "flagged" as deleted. Mongoid-paranoia provides a Paranoia module to give you just that.

**Old API** from Mongoid 3.0 is extracted in [3.0.0-stable branch](https://github.com/simi/mongoid-paranoia/tree/3.0.0-stable) and **doesn't work** with **Mongoid 4** anymore.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid-paranoia', github: 'simi/mongoid-paranoia' # before first release
```

## Changes in 4.0

### Uniqueness validator is not overriden

#### Old syntax:
```ruby
validates_uniqueness_of :title
validates :title, :uniqueness => true
```

#### New syntax:
```ruby
validates :title, uniqueness: { conditions: -> { where(deleted_at: nil) } }
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

### Callbacks

`before_restore`, `after_restore` and `around_restore` callbacks are added to your model. They work similarly to the `before_destroy`, `after_destroy` and `around_destroy` callbacks.

```ruby
class User
  include Mongoid::Document
  include Mongoid::Paranoia
  
  before_restore :before_restore_action
  after_restore  :after_restore_action
  around_restore :around_restore_action

  private

  def before_restore_action
    puts "BEFORE"
  end

  def after_restore_action
    puts "AFTER"
  end
  
  def around_restore_action
    puts "AROUND - BEFORE"
    yield # restoring
    puts "AROUND - AFTER"
  end
end
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
