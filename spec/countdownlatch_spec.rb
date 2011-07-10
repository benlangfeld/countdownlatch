require 'minitest/autorun'
require 'countdownlatch'

describe CountDownLatch do
  it "requires a positive count" do
    assert_raises(ArgumentError) { CountDownLatch.new(-1) }
  end

  describe "#wait" do
    describe "counting down from 1" do
      before do
        @latch = CountDownLatch.new 1
        @name = :foo
      end

      it "blocks until counted down in another thread" do
        Thread.new do
          @name = :bar
          @latch.countdown!
        end
        @latch.wait
        @latch.count.must_equal 0
        @name.must_equal :bar
      end

      it "blocks another thread until counted down" do
        Thread.new do
          @latch.wait
          @latch.count.must_equal 0
          @name.must_equal :bar
        end
        @name = :bar
        @latch.countdown!
      end

      it "returns true if counted down" do
        Thread.new { @latch.countdown! }
        @latch.wait.must_equal true
      end

      it "returns true if timed out" do
        @latch.wait(0.01).must_equal false
      end
    end

    describe "counting down from zero" do
      before do
        @latch = CountDownLatch.new 0
      end

      it "does not wait" do
        @latch.wait
        @latch.count.must_equal 0
      end
    end

    describe "counting down from 2" do
      before do
        @latch = CountDownLatch.new 2
        @name = :foo
      end

      it "within a single thread" do
        Thread.new do
          @latch.countdown!
          @name = :bar
          @latch.countdown!
        end
        @latch.wait
        @latch.count.must_equal 0
        @name.must_equal :bar
      end

      it "within two parallel threads" do
        Thread.new { @latch.countdown! }
        Thread.new do
          @name = :bar
          @latch.countdown!
        end
        @latch.wait
        @latch.count.must_equal 0
        @name.must_equal :bar
      end

      it "within two chained threads" do
        Thread.new do
          @latch.countdown!
          Thread.new do
            @name = :bar
            @latch.countdown!
          end
        end
        @latch.wait
        @latch.count.must_equal 0
        @name.must_equal :bar
      end
    end

    describe "with multiple waiters" do
      before do
        @proceed_latch = CountDownLatch.new 2
        @check_latch = CountDownLatch.new 2
        @results = {}
      end

      it "executes in the correct order" do
        Thread.new do
          @proceed_latch.wait
          @results[:first] = 1
          @check_latch.countdown!
        end
        Thread.new do
          @proceed_latch.wait
          @results[:second] = 2
          @check_latch.countdown!
        end
        @results.must_equal({})
        2.times { @proceed_latch.countdown! }
        @check_latch.wait
        @proceed_latch.count.must_equal 0
        @check_latch.count.must_equal 0
        @results.must_equal :first => 1, :second => 2
      end
    end

    describe "with interleaved latches" do
      before do
        @change_1_latch = CountDownLatch.new 1
        @check_latch = CountDownLatch.new 1
        @change_2_latch = CountDownLatch.new 1
        @name = :foo
      end

      it "blocks the correct thread" do
        Thread.new do
          @name = :bar
          @change_1_latch.countdown!
          @check_latch.wait
          @name = :man
          @change_2_latch.countdown!
        end
        @change_1_latch.wait
        @name.must_equal :bar
        @check_latch.countdown!
        @change_2_latch.wait
        @name.must_equal :man
      end
    end
  end
end