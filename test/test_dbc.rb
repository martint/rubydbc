$LOAD_PATH << '../lib'

require 'test/unit'
require 'dbc'

class TestDBC < Test::Unit::TestCase
	def test_instance_vars
		c = Class.new {
			include DesignByContract

			def initialize
				@v = 1
			end

			pre { @v == 1 }
			def method_1
			end

			post { @v == 1 }
			def method_2
			end

			pre { @v == 2 }
			def method_3
			end

			post { @v == 2 }
			def method_4
			end
		}	

		assert_nothing_raised { c.new.method_1 }
		assert_nothing_raised { c.new.method_2 }
		assert_raise(RuntimeError) { c.new.method_3 }
		assert_raise(RuntimeError) { c.new.method_4 }
	end


	def test_pre_explicit
		c = Class.new {
			include DesignByContract
		
			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			pre(:method_1) { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(!o.method_1_called)
	end

	def test_post_explicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			post(:method_1) { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
	end


	def test_pre_and_post_explicit
		c = Class.new {
			include DesignByContract
	
			attr_reader :method_1_called
			attr_reader :method_2_called

			def initialize
				@method_1_called = false
				@method_2_called = false
			end

			pre(:method_1) { true }
			post(:method_1) { false }
			def method_1
				@method_1_called = true
			end

			pre(:method_2) { false }
			post(:method_2) { true }
			def method_2
				@method_2_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
		assert_raise(RuntimeError) { o.method_2 }
		assert(!o.method_2_called)
	end


	def test_multi_post_explicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			post(:method_1) { true }
			post(:method_1) { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
	end

	def test_multi_pre_explicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			pre(:method_1) { true }
			pre(:method_1) { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(!o.method_1_called)
	end


	def test_pre_implicit
		c = Class.new {
			include DesignByContract
		
			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			pre { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(!o.method_1_called)
	end

	def test_post_implicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			post { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
	end


	def test_pre_and_post_implicit
		c = Class.new {
			include DesignByContract
	
			attr_reader :method_1_called
			attr_reader :method_2_called

			def initialize
				@method_1_called = false
				@method_2_called = false
			end

			pre { true }
			post { false }
			def method_1
				@method_1_called = true
			end

			pre { false }
			post { true }
			def method_2
				@method_2_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
		assert_raise(RuntimeError) { o.method_2 }
		assert(!o.method_2_called)
	end


	def test_multi_post_implicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			post { true }
			post { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
	end

	def test_multi_pre_implicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			pre { true }
			pre { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(!o.method_1_called)
	end


	def test_pre_implicit
		c = Class.new {
			include DesignByContract
		
			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			pre { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(!o.method_1_called)
	end

	def test_post_implicit
		c = Class.new {
			include DesignByContract

			attr_reader :method_1_called

			def initialize
				@method_1_called = false
			end

			post { false }
			def method_1
				@method_1_called = true
			end
		}	

		o = c.new
		assert_raise(RuntimeError) { o.method_1 }
		assert(o.method_1_called)
	end

end
