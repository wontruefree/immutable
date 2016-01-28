module Immutable
  class Vector(T)
    @trie : Trie(T)
    @tail : Array(T)

    def initialize
      @trie = Trie(T).empty
      @tail = [] of T
    end

    def initialize(@trie : Trie(T), @tail : Array(T))
    end

    def size
      @trie.size + @tail.size
    end

    def each
      @trie.each { |elem| yield elem }
      @tail.each { |elem| yield elem }
      self
    end

    def each
      ItemIterator.new(self)
    end

    def each_index
      i = 0
      while i < size
        yield i
        i += 1
      end
      self
    end

    def push(elem : T)
      new_tail = @tail + [elem]
      if new_tail.size == Immutable::Trie::BLOCK_SIZE
        Vector.new(@trie.push_leaf(new_tail), [] of T)
      else
        Vector.new(@trie, new_tail)
      end
    end

    def <<(elem : T)
      push(elem)
    end

    def [](i : Int)
      at(i)
    end

    def at(i : Int)
      at(i) { raise IndexError.new }
    end

    def at(i : Int)
      i = size + i if i < 0
      return yield if i < 0 || i >= size
      return @tail[i - @trie.size] if in_tail?(i)
      @trie.get(i)
    end

    def first
      self[0]
    end

    def last
      self[-1]
    end

    private def in_tail?(index)
      index >= @trie.size && index < size
    end

    class ItemIterator(T)
      include Iterator(Int32)

      @vector : Vector(T)
      @index : Int32

      def initialize(@vector : Vector(T), @index = 0)
      end

      def next
        value = @vector.at(@index) { stop }
        @index += 1
        value
      end
    end
  end
end
