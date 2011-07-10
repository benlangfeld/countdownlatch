require "countdownlatch/version"

require 'thread'
require 'timeout'

##
# A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes.
#
# Mirrors the Java implementation: http://download.oracle.com/javase/1.5.0/docs/api/java/util/concurrent/CountDownLatch.html
#
# @author Ben Langfeld
# @author Tuomas Kareinen (derivative): https://gist.github.com/739662
#
# @example Count down from 2 in 2 seconds, with a timeout of 10 seconds
#   latch = CountDownLatch.new 2
#
#   Thread.new do
#     2.times do
#       sleep 1
#       latch.countdown!
#     end
#   end
#
#   latch.wait 10
#
class CountDownLatch
  ##
  # Create a new CountDownLatch
  # @param [Integer] count the number of times #countdown! must be invoked before threads can pass through #wait
  #
  # @raise [ArgumentError] if the count is less than zero
  #
  def initialize(count)
    raise ArgumentError if count < 0
    @count = count
    @mutex = Mutex.new
    @conditional = ConditionVariable.new
  end

  ##
  # Decrements the count of the latch, releasing all waiting threads if the count reaches zero.
  # * If the current count is greater than zero then it is decremented. If the new count is zero then all waiting threads are re-enabled for thread scheduling purposes.
  # * If the current count equals zero then nothing happens.
  #
  def countdown!
    @mutex.synchronize do
      @count -= 1 if @count > 0
      @conditional.broadcast if @count == 0
    end
  end

  ##
  # Returns the current count.
  # This method is typically used for debugging and testing purposes.
  #
  # @return [Integer]
  #
  def count
    @mutex.synchronize { @count }
  end

  ##
  # Returns a string identifying this latch, as well as its state. The state, in brackets, includes the String "Count =" followed by the current count.
  #
  # @return [String]
  #
  def to_s
    super.insert -2, " (Count = #{count})"
  end

  ##
  # Causes the current thread to wait until the latch has counted down to zero, unless the thread is interrupted.
  # If the current count is zero then this method returns immediately.
  # If the current count is greater than zero then the current thread becomes disabled for thread scheduling purposes and lies dormant until one of three things happen:
  # * The count reaches zero due to invocations of the countdown! method; or
  # * Some other thread interrupts the current thread; or
  # * The specified waiting time elapses.
  #
  # @param [Integer] timeout the maximum time to wait in seconds
  #
  # @return [Boolean] true if the count reached zero and false if the waiting time elapsed before the count reached zero
  #
  def wait(timeout = nil)
    begin
      Timeout::timeout timeout do
        @mutex.synchronize do
          @conditional.wait @mutex if @count > 0
        end
      end
      true
    rescue Timeout::Error
      false
    end
  end
end
