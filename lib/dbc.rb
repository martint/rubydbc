#  Copyright 2010 Martin Traverso, Brian McCallister
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

module DesignByContract
	@@pending = Hash.new { |hash, key| hash[key] = {} }
	
	private 

	def self.extract(this, method_name, message)
		if method_name.respond_to?(:to_str)
			# no method symbol specified, just the message
			message = method_name
			method_name = nil
		elsif !method_name.nil? && this.method_defined?(method_name)
			old_method = this.instance_method(method_name) 
		end

		return old_method, method_name, message
	end
	
	def self.schedule(type, mod, method_name, message, condition)
		@@pending[mod][method_name] ||= []
		@@pending[mod][method_name] << {:type => type, :message => message, :condition => condition}
	end

	def self.included(mod)
		old_method_added = mod.method :method_added

		new_method_added = lambda { |id| 			
			if @@pending.has_key? mod
				# save the list of methods and clear the entry
				# otherwise, we'll have infinite recursion on the call to mod.send(...)
				hooks = @@pending[mod].values_at(id, nil).compact.flatten
				@@pending[mod].delete id
				@@pending[mod].delete nil

				# define scheduled hooks
				hooks.each do |entry|
					mod.send entry[:type], id, entry[:message], &entry[:condition]
				end
			end
			
			old_method_added.call id
		}
		
		(class << mod; self; end).send :define_method, :method_added, new_method_added
		
		class << mod
			def pre(method_name = nil, message = nil, &condition)
				old_method, method_name, message = DesignByContract.extract self, method_name, message

				unless old_method.nil?
					# make a method out of the condition so that we can bind it against self
					# and pass it the arguments (it'd be easier if instance_eval accepted arguments...)
					define_method(method_name, &condition)
					condition_method = instance_method(method_name)
					define_method(method_name) { |*args|
						unless condition_method.bind(self).call(*args)
							raise "Pre-condition #{'\'' + message + '\' ' if message}failed"
						end

						old_method.bind(self).call(*args)
					}
				else
					DesignByContract.schedule :pre, self, method_name, message, condition 
				end
			end

			def post(method_name = nil, message = nil, &condition)
				old_method, method_name, message = DesignByContract.extract self, method_name, message

				unless old_method.nil?
					# make a method out of the condition so that we can bind it against self
					# and pass it the arguments (it'd be easier if instance_eval accepted arguments...)
					define_method(method_name, &condition)
					condition_method = instance_method(method_name)
					define_method(method_name) { |*args|
						result = old_method.bind(self).call(*args)
						unless condition_method.bind(self).call(result, *args)
							raise "Post-condition #{'\'' + message + '\' ' if message}failed" 
						end
						return result
					}
				else
					DesignByContract.schedule :post, self, method_name, message, condition 
				end
			end
		end
	end
end
