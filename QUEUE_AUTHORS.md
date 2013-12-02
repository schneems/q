# Queue Authors

This document explains how to make your queuing library compatible with the `Q` interface.

You can see existing implementations in `lib/q/methods` for reference implementations.

## Background

The primary focus of this project is usability for the end user. Ideally they should know as little as possible about a queueing implementation to be able to push a job to the background. To fully manage a queuing library we need to be able to do 4 things:

- Create background tasks
- Enqueue background tasks
- Run background tasks
- Configure the background library

To integrate with `Q` you need to add these abilities programatically. While `Q::Methods::Base` does a lot of heavy lifting (as you'll see) you still need to do a fair amount of meta programming to make all this possible.

For demonstration sake we'll use a fictitious background queuing library called `FooQueue`. It will be very similar to Resque 1.x in implementation.

## How to Include Your Module with Q

There are default implementations for several queuing libraries included with `Q` if you own one of them, we invite you to add `Q` as a gem requirement, and then to over-write over-write

## Basics

You will need to create a module that is included in other classes/modules. Create a module in your gem `lib/q/methods/foo_queue.rb`. Inside of that file you'll need to define your module and include the `Q::Methods::Base` module:

```ruby
module Q::Methods::FooQueue
  include Q::Methods::Base
end
```

Of course this will mean that you have `require 'q'` somewhere previously in your code. Everything we need to integrate with `Q` will go in this module.

To work you'll need the following constants defined in your code:

- QueueMethod
- QueueBuild
- QueueTask
- QueueConfig

You can add them as classes:

```ruby
module Q::Methods::FooQueue
  include Q::Methods::Base

  class QueueBuild
  end
  class QueueMethod
  end
  class QueueTask
  end
  class QueueConfig
  end
end
```

## Create Background Tasks

Without the `Q` library you would need to define a `FooQueue` task as a class:

```
class SendEmail
  @queue = :send_email

  def self.perform(id, state)
    user   = User.find(id)
    issues = user.issues.where(state: state).all
    UserMailer.send_issues(user: user, issues: issues).deliver
  end
end
```

You need to be able to build the exact same class with `Q` programatically. To do this you need to add a `QueueBuild` constant to your module:

```ruby
module Q::Methods::FooQueue
  include Q::Methods::Base

  class QueueBuild
  end
end
```

This `QueueBuild` constant needs to respond to `call` and accept options hash and a proc with the task contents. In this case the proc it receives will look something like this:

```ruby
Proc.new do |id, state|
  user   = User.find(id)
  issues = user.issues.where(state: state).all
  UserMailer.send_issues(user: user, issues: issues).deliver
end
```

The options will contain:


```ruby
options[:base]             # this is the class/module that your code is being included into
options[:queue_name]       # in our example this would be :send_email
options[:queue_klass_name] # in our example this would be SendEmail
```

You can pull these out:

```ruby
class QueueBuild
  def self.call(options={}, &job)
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]
  end
end
```

Now we want to build a new class that will hold our task:

```ruby
class QueueBuild
  def self.call(options={}, &job)
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass = Class.new do
    end
  end
end
```

We need a perform method and to set the `@queue` instance variable on the class, and pass in the job, we can do this by creating accessors on our class:

```ruby
class QueueBuild
  def self.call(options={}, &job)
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass = Class.new do
      def self.perform(*args)
        @job.call(*args)
      end

      def self.job=(job)
        @job = job
      end

      def self.queue=(queue)
        @queue = queue
      end
    end
  end
end
```

This example will get a bit longer as we go, try to focus on the new code to keep from being overwhelmed.

Now that we can set our `@queue` and `@job` instance variables, we need to do so:

```ruby
class QueueBuild
  def self.call(options={}, &job)
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass = Class.new do
      def self.perform(*args)
        @job.call(*args)
      end

      def self.job=(job)
        @job = job
      end

      def self.queue=(queue)
        @queue = queue
      end


      queue_klass.job   = job
      queue_klass.queue = queue_name
    end
  end
end
```

We're almost done, the last thing we need is to assign this anonomous class to a constant so we can find it when we want to do the work:


```ruby
class QueueBuild
  def self.call(options={}, &job)
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass = Class.new do
      def self.perform(*args)
        @job.call(*args)
      end

      def self.job=(job)
        @job = job
      end

      def self.queue=(queue)
        @queue = queue
      end


      queue_klass.job   = job
      queue_klass.queue = queue_name

      base.const_set(queue_klass_name, queue_klass)
    end
  end
end
```

Now when this code gets run by the `Q` library, this:

```ruby
class Poro
  include Q::Methods::FooQueue

  queue(:send_issues) do |id, state|
    user   = User.find(id)
    issues = user.issues.where(state: state).all
    UserMailer.send_issues(user: user, issues: issues).deliver
  end
end
```

Will produce the equivalent code of this:

```
class Poro
  class SendEmail
    @queue = :send_email

    def self.perform(id, state)
      user   = User.find(id)
      issues = user.issues.where(state: state).all
      UserMailer.send_issues(user: user, issues: issues).deliver
    end
  end
end
```

It may not look like much of a savings, but the nice this is that someone who wrote their code to use say the `Resque` backend can now switch to the `FooQueue` backend with little or no code changes.

## Naming Convention

The name of your module is important. With `Q` you can specify the queueing library in an initializer like this:

```ruby
Q.setup do |config|
  config.queue = :resque
end
```

Since you created a `Q::Methods::FooQueue` module a user can now configure their queue:


```ruby
Q.setup do |config|
  config.queue = :foo_queue
end
```

If you want to be more precise you can bypass the symbol to module lookup by haing your user pass in a module directly:

```ruby
Q.setup do |config|
  config.queue = Q::Methods::FooQueue
end
```

Once configured users can use the generic include:

```ruby
class Poro
  include Q::Methods
end
```

Instead of having to explicitly include your module:

```ruby
class Poro
  include Q::Methods::FooQueue
end
```

## Enqueue Background Tasks

Once your task is defined correctly in the code you need a way to call it. Our ficticious `FooQueue` library allows you to process our `SendEmail` task that we defined previously in the background like this:

```ruby
user = User.first
FooQueue.enqueue(Poro::SendEmail, user.id, 'open')
```

We must be able to acomplish this same thing in our `QueueMethod.call()` method call:


```ruby
module Q::Methods::FooQueue
  include Q::Methods::Base

  class QueueMethod
    def self.call(options = {})
    end
  end
end
```

Here options are:

```ruby
options[:base]             # this is the class/module that your code is being included into
options[:queue_name]       # in our example this would be :send_email
options[:queue_klass_name] # in our example this would be SendEmail
```

```ruby
module Q::Methods::FooQueue
  include Q::Methods::Base

  class QueueMethod
    def self.call(options = {})
      base             = options[:base]
      queue_name       = options[:queue_name]
      queue_klass_name = options[:queue_klass_name]
    end
  end
end
```

To enqueue our job we'll need the klass reference not just the name:

```ruby
class QueueMethod
  def self.call(options = {})
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass      = base.const_get(queue_klass_name)
  end
end
```

Now you need to define a method on our queue object using `define_singleton_method`:

```ruby
class QueueMethod
  def self.call(options = {})
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass      = base.const_get(queue_klass_name)

    base.queue.define_singleton_method(queue_name) do |*args|

    end
  end
end
```

The code we want to emulate needs to go in this programatically created method:

```ruby
class QueueMethod
  def self.call(options = {})
    base             = options[:base]
    queue_name       = options[:queue_name]
    queue_klass_name = options[:queue_klass_name]

    queue_klass      = base.const_get(queue_klass_name)

    base.queue.define_singleton_method(queue_name) do |*args|
      FooQueue.enqueue(queue_klass, *args)
    end
  end
end
```

Now when a user calls this:

```ruby
user = User.first
Poro.queue.send_email(user.id, 'open')
```

It will be exactly the same as this code:

```
user = User.first
FooQueue.enqueue(Poro::SendEmail, user.id, 'open')
```

Now your code will create a queue, and create background jobs for that queue. All we have left is running your background workers and configuration.

## Convention: JSON

While your queue may accept any type of data, not all other queues will. To maximize compatability you should build your `QueueMethod` and `QueueBuild` to only rely on JSON compatible ruby data types (arrays, strings, numbers, hashes). If you don't then you're defeating the whole purpose of writing an integration with `Q` as other users will not be able to use their previously written `Q` compatible apps with your adapter.


## Running Workers

To run the mythical `FooQueue` background workers users must run this rake task:

```ruby
$ bundle exec rake foo_queue:work VVERBOSE=1 QUEUE=*
```

The task is `foo_queue:work` and `VVERBOSE` is an environment variable specifying the log level, and `QUEUE` is an environment variable specifying which queues to run, in our case we want to run all of them.

We must call this programmatically in our module with the help of our `BuildTask` constant:

```ruby
module Q::Methods::FooQueue
  include Q::Methods::Base

  class QueueTask
    def self.call(*rake_args)
    end
  end
end
```

Here `*rake_args` are any arguments that may need to be passed into the task. In our example above we're not using any, but your non-fictitious queuing library might:

```ruby
$ rake your_queue:work[1,2,3]
```


