# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NonNamespacedClass, :config do
  let(:msg) { 'Do not add new classes that are not namespaced [...]' }

  it 'reports non-namespaced classes' do
    expect_offense(<<~RUBY)
      class Foo
      ^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'reports non-namespaced classes with inheritance' do
    expect_offense(<<~RUBY)
      class Foo < Bar
      ^^^^^^^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'does not report classes inside a module' do
    expect_no_offenses(<<~RUBY)
      module MyNamespace
        class Foo
        end
      end
    RUBY
  end

  it 'does not report classes inside nested modules' do
    expect_no_offenses(<<~RUBY)
      module Outer
        module Inner
          class Foo
          end
        end
      end
    RUBY
  end

  it 'does not report classes using :: syntax' do
    expect_no_offenses(<<~RUBY)
      class MyNamespace::Foo
      end
    RUBY
  end

  it 'does not report classes using nested :: syntax' do
    expect_no_offenses(<<~RUBY)
      class Outer::Inner::Foo
      end
    RUBY
  end

  it 'does not report nested classes when outer class is in module' do
    expect_no_offenses(<<~RUBY)
      module Namespace
        class Outer
          class Inner
          end
        end
      end
    RUBY
  end

  it 'reports top-level class but not inner nested class' do
    expect_offense(<<~RUBY)
      class Outer
      ^^^^^^^^^^^ #{msg}
        class Inner
        end
      end
    RUBY
  end

  it 'reports multiple non-namespaced classes' do
    expect_offense(<<~RUBY)
      class Foo
      ^^^^^^^^^ #{msg}
      end

      class Bar
      ^^^^^^^^^ #{msg}
      end
    RUBY
  end

  it 'registers namespaced classes even with non-namespaced classes in same file' do
    expect_offense(<<~RUBY)
      class TopLevel
      ^^^^^^^^^^^^^^ #{msg}
      end

      module MyNamespace
        class Foo
        end
      end
    RUBY
  end

  it 'does not report allowed classes' do
    temp = cop.allowed_classes
    cop.allowed_classes = [:Foo]

    expect_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  ensure
    cop.allowed_classes = temp
  end

  it 'still reports non-allowed classes when some are allowed' do
    temp = cop.allowed_classes
    cop.allowed_classes = [:Foo]

    expect_offense(<<~RUBY)
      class Bar
      ^^^^^^^^^ #{msg}
      end
    RUBY
  ensure
    cop.allowed_classes = temp
  end

  it 'does not report allowed class or its nested classes' do
    temp = cop.allowed_classes
    cop.allowed_classes = [:Outer]

    expect_no_offenses(<<~RUBY)
      class Outer
        class Inner
        end
      end
    RUBY
  ensure
    cop.allowed_classes = temp
  end
end
