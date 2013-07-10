## Q

Forget queue boilerplate: focus on your code.





## Install

In your `Gemfile` add:

```ruby
gem 'q'
```

Then run `$ bundle install`

## What

Q is an interface for your queues. Are you using Resque, Sidekiq, delayed_job, queue_classic, or some other queue? Awesome sauce, because with `Q` you can write your queuing code once and re-use against different backends.

```ruby
Q.configure do |config|
  config.global_queue = :resque
end
```

Now in your code when you need to enqueue something first you need to

```ruby
class Poro
  include Q::Methods
end
```

Now you can define tasks:

```ruby
class Poro
  include Q::Methods


  queue(:send_issues) do |id, state|
    user   = User.find(id)
    issues = user.issues.where(state: state).all
    UserMailer.send_issues(user: user, issues: issues).deliver
  end
end
```

And enqueue new tasks:

```ruby
user  = User.last
state = 'open'
Poro.queue.send_issues(user.id, state)
```

The Q interface expects json-able objects, numbers, arrays, hashes, etc. This is important if you want your code to be re-usable across multiple queue backends.


## Config

This gems supports configuring options across queues.

**inline**

```ruby
Q.inline = true
```

If the underlying queue supports it, the `inline` option will bypass the queueing behavior and run code as it comes. This is very convienent for testing. If a queue does not support this option, an error will be raised.


## Queue Specific Config

You may find yourself needing to configure options that are specific to the queue you are using

```ruby
```

## No Queue? No Problem

The `Q` library comes with a threaded queue that does not need a backend (such as redis) by default, so you can write your code today and figure out what queue you want to use tomorrow. Note that this threaded queue is very basic and should not be used in production.


## Fun with Blocks

You can set default values in blocks like this:

```ruby
queue(:foo) do |id, state = 'open', username = 'schneems'|
  # ...
end
```

You can have an unlimited amount of args using a splat:

```ruby
queue(:foo) do |id, *args|
  # ...
end
```

## License

MIT