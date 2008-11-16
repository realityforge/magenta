RUBY=ruby

main: target/magenta

generated: 
	mkdir -p generated

target: 
	mkdir -p target

generated/execution-engine.c: src/main/ruby/example.rb generated
	$(RUBY) src/main/ruby/example.rb
	
generated/stack-accessors.c: src/main/ruby/example.rb generated
	$(RUBY) src/main/ruby/example.rb
	
target/magenta: target generated/stack-accessors.c generated/execution-engine.c src/main/c/engine.c src/main/c/support.h
	gcc -o target/magenta src/main/c/engine.c -I generated/