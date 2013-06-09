## ResqueDef

Forget resque boilerplate: focus on your code.

## Install

In your `Gemfile` add:

```ruby
gem 'resque_def'
```

Then run `$ bundle install`

## What

I love Resque, but I'm not in love with the amount of code needed to define and use a Resque task to do something like pull a user from a database, find open issues (assuming an issue model) and sending an email might look like this:

```ruby
class User < ActiveRecord::Base

  class DelaySendIssues
    @queue = :delay_send_issues

    def self.perform(id, state)
      user   = User.find(id)
      issues = user.issues.where(state: state).all
      UserMailer.send_issues(user: user, issues: issues).deliver
    end
  end
end

user = User.last
Resque.enqueue(User::SendDailyTriageEmail, user.id, 'open')
```

With ResqueDef, you can include a module, and define and use a Resque job like this:

```ruby
class User < ActiveRecord::Base
  include ResqueDef

  resque_def(:delay_send_issues) do |id, state|
    user   = User.find(id)
    issues = user.issues.where(state: state).all
    UserMailer.send_issues(user: user, issues: issues).deliver
  end
end

user = User.last
User.delay_send_issues(user.id, 'open')
```

So looking at the boiler plate (and none of the logic) we are reducing this:


```ruby
  class DelaySendIssues
    @queue = :delay_send_issues

    def self.perform(id, state)
    end
  end
```

To this:

```ruby
resque_def(:delay_send_issues) do |id, state|
end
```

Pretty cool, huh? To do this, ResqueDef uses simple metaprogramming: `Class.new` is used to define the require class, and then `define_singleton_method` adds our method to the class included `ResqueDef`. Not doing anything too magical. Check out the code for yourself!


## Serializing Objects

By default Resque can only store JSON-able objects (strings, arrays, hashes, booleans). It cannot store active record objects.

## TIL with Blocks

You can set default values in blocks like this:

```ruby
resque_def(:foo) do |id, state = 'open', username = 'schneems'|
  # ...
end
```

You can have an unlimited amount of args using a splat:

```ruby
resque_def(:foo) do |id, *args|
  # ...
end
```

## License

MIT