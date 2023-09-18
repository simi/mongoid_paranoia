# Paranoid Documents for Mongoid
[![Build Status](https://travis-ci.org/simi/mongoid_paranoia.svg?branch=master)](https://travis-ci.org/simi/mongoid_paranoia) [![Gem Version](https://img.shields.io/gem/v/mongoid_paranoia.svg)](https://rubygems.org/gems/mongoid_paranoia) [![Gitter chat](https://badges.gitter.im/simi/mongoid_paranoia.svg)](https://gitter.im/simi/mongoid_paranoia)

`Mongoid::Paranoia` enables a "soft delete" of Mongoid documents.
Instead of being removed from the database, paranoid docs are flagged
with a `deleted_at` timestamp and are ignored from queries by default.

The `Mongoid::Paranoia` functionality was originally supported in Mongoid
itself, but was dropped from version 4.0 onwards. This gem was extracted
from the [Mongoid 3.0.0-stable branch](https://github.com/mongodb/mongoid/tree/3.0.0-stable).

**Caution:** This repo/gem `mongoid_paranoia` (underscored) is different than [mongoid-paranoia](https://github.com/haihappen/mongoid-paranoia) (hyphenated). The goal of `mongoid-paranoia` (hyphenated) is to stay API compatible and it only accepts security fixes.

## Version Support

* The current release is compatible with Mongoid 7.3 and later, and Ruby 2.7 and later.
* Earlier Mongoid and Ruby versions are supported on earlier releases.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_paranoia'
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
person.restore(:recursive => true) # Brings "deleted" associated documents back to life recursively
```

The documents that have been "flagged" as deleted (soft deleted) can be accessed at any time by calling the deleted class method on the class.

```ruby
Person.deleted # Returns documents that have been "flagged" as deleted.
```

You can also access all documents (both deleted and non-deleted) at any time by using the `unscoped` class method:

```ruby
Person.unscoped.all # Returns all documents, both deleted and non-deleted
```

You can also configure the paranoid field naming on a global basis.  Within the context of a Rails app this is done via an initializer.

```ruby
# config/initializers/mongoid_paranoid.rb

Mongoid::Paranoia.configure do |c|
  c.paranoid_field = :myFieldName
end
```

### Validations
#### You need override uniqueness validates

```ruby
validates :title, uniqueness: { conditions: -> { where(deleted_at: nil) } }
```

### Callbacks

#### Restore
`before_restore`, `after_restore` and `around_restore` callbacks are added to your model. They work similarly to the `before_destroy`, `after_destroy` and `around_destroy` callbacks.

#### Remove
`before_remove`, `after_remove` and `around_remove` are added to your model. They are called when record is deleted permanently .

#### Example
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
- get rid of [monkey_patches.rb](https://github.com/simi/mongoid_paranoia/blob/master/lib/mongoid/paranoia/monkey_patches.rb)
- [review persisted? behaviour](https://github.com/simi/mongoid_paranoia/issues/2)

## Authors

* original [Mongoid](https://github.com/mongoid/mongoid) implementation by [@durran](https://github.com/durran)
* extracted from [Mongoid](https://github.com/mongoid/mongoid) by [@simi](https://github.com/simi)
* [documentation improvements](https://github.com/simi/mongoid_paranoia/pull/3) by awesome [@loopj](https://github.com/loopj)
* [latest mongoid support, restore_callback support](https://github.com/simi/mongoid_paranoia/pull/8) by fabulous [@zhouguangming](https://github.com/zhouguangming)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
