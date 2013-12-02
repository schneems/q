## Q

Forget queue boilerplate: focus on your code.

## Install

In your `Gemfile` add:

```ruby
gem 'q'
```

Then run `$ bundle install`

## What

Q is an interface for your background queues. Are you using Resque, Sidekiq, delayed_job, queue_classic, or some other queue? Awesome sauce, because with `Q` you can write your queuing code once and re-use against different backends.

```ruby
Q.setup do |config|
  config.queue = :resque
end
```

Now in your code when you need to enqueue something first you need to add the `Q::Methods` module:

```ruby
class Poro
  include Q::Methods
end
```

Now you can define tasks using the `queue` class method like this:

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

Here we're building a background task called `send_issues` that will send out an email when executed.

Now that the task is defined, you can enqueue a `send_issues` job to be executed later by calling `queue` and then `send_issues` like this:

```ruby
user  = User.last
state = 'open'
Poro.queue.send_issues(user.id, state)
```

The Q interface expects json-able objects, numbers, arrays, hashes, etc. This is important if you want your code to be re-usable across multiple queue backends.

## No Queue? No Problem

The `Q` library comes with a threaded queue that does not need a backend (such as Redis) by default, so you can write your code today and figure out what queue you want to use tomorrow.

Note: that this threaded queue is very basic and should not be used in production. If you stop your Ruby process while there are jobs in memory you will lose your jobs see [threaded_in_memory_queue](https://github.com/schneems/threaded_in_memory_queue) for more information.

## Starting your Queue

Most background queue libraries must be run in a seperate process. The `Q` library makes starting these background tasks easy.

Make sure there is a Rake task named `:environment` that loads your app (Rails provides one by default). Then add this line to your `Procfile`:

```
worker: bundle exec rake q:work
```

Now if you are running on Heroku the background task will automatically be run. Locally you can run the task manually by executing:

```sh
$ bundle exec rake q:work
```

Or through your `Procfile` with foreman:

```sh
$ foreman start
```

If your queueing library supports any custom environment variables or flags you can add them to your `rake q:work` command and they will be passed to the supporting background queue's task.

Note: the default threaded queue does not need to be started as it runs in your web process

## Config

You can configure the behavior of your background queue using `Q.queue_config`. For example if you are using Resque and want to run commands inline you could execute:

```ruby
Q.queue_config.inline = true
```

Now any calls to `enqueue` will bypass resque and be run immediately. Different queues will have different configuration options so you will need to see their docs for configuration options.

You can access this config in the setup command:

```ruby
Q.setup do |config|
  config.queue = :resque
  config.queue_config.inline = true
end
```

It also accepts a block:

```ruby
Q.queue_config do |config|
  config.inline = true
end
```

Don't confuse `queue_config` which will configure your background queue (such as Resque) with `setup` which configures the `Q` library itself.

## Diverging Backends

As much as we try to make all front end code similar, you'll still need to setup your queue. To make sqitching back and forth easier, we provide a `Q.env` object that responds to the backend you are using such as `Q.env.resque?`.

That way you could keep multiple queue configurations in your app and it won't raise any errors if you're running a different backend.

```ruby
if Q.env.resque?
  # config resque here
end

if Q.env.sidekiq?
  # configure sidekiq here
else
```

## Supported Queue Backends

```
config.queue = :sidekiq
config.queue = :resque
config.queue = :threaded
```

Coming soon:

```
config.queue = :delayed_job
```



## Blocks

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


## Q Authors

Did you write a background queuing library? Want to add support for the `Q` interface? Check out the [QUEUE_AUTHORS.md](QUEUE_AUTHORS.md) file to get started.

## License

Brought to you by [@schneems](http://twitter.com/schneems)

MIT