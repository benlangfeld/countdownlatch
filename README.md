# CountDownLatch [ ![Build status](http://travis-ci.org/benlangfeld/countdownlatch.png) ](http://travis-ci.org/benlangfeld/countdownlatch)
A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes

## Installation
    gem install countdownlatch

## Usage
```ruby
require 'countdownlatch'

latch = CountDownLatch.new 2

Thread.new do
  2.times do
    sleep 1
    latch.countdown!
  end
end

latch.wait 10
```

## Links
* [Source](https://github.com/benlangfeld/countdownlatch)
* [Documentation](http://rdoc.info/github/benlangfeld/countdownlatch/master/CountDownLatch)
* [Bug Tracker](https://github.com/benlangfeld/countdownlatch/issues)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Ben Langfeld, Tuomas Kareinen. MIT licence (see LICENSE for details).
