module Rambling
  module Trie
    # A representation of a node in an compressed Trie data structure.
    class CompressedNode < Rambling::Trie::Node
      # Always raises [Rambling::Trie::InvalidOperation] when trying to add a
      # branch to the current trie node based on the word
      # @param [String] word the word to add the branch from.
      # @raise [InvalidOperation] if the trie is already compressed.
      def add word
        raise Rambling::Trie::InvalidOperation, 'Cannot add branch to compressed trie'
      end

      # Checks if a path for set of characters exists in the trie.
      # @param [Array] chars the characters to look for in the trie.
      # @return [Boolean] `true` if the characters are found, `false` otherwise.
      def partial_word? chars
        chars.empty? || has_partial_word?(chars)
      end

      # Checks if a path for set of characters represents a word in the trie.
      # @param [Array] chars the characters to look for in the trie.
      # @return [Boolean] `true` if the characters are found and form a word,
      # `false` otherwise.
      def word? chars
        chars.empty? ? terminal? : has_word?(chars)
      end

      # Returns all words that start with the specified characters.
      # @param [Array] chars the characters to look for in the trie.
      # @return [Array] all the words contained in the trie that start with the specified characters.
      def scan chars
        chars.empty? ? self : closest_node(chars)
      end

      # Always return `true` for a raw (compressed) node.
      # @return [Boolean] always true for a raw (compressed) node.
      def compressed?
        true
      end

      private

      def has_partial_word? chars
        recursive_get(:partial_word?, chars) || false
      end

      def has_word? chars
        current_key = nil

        while !chars.empty?
          if current_key
            current_key << chars.slice!(0)
          else
            current_key = chars.slice!(0)
          end

          child = children_tree[current_key.to_sym]
          return child.word? chars if child
        end

        false
      end

      def closest_node chars
        recursive_get(:scan, chars) || Rambling::Trie::MissingNode.new
      end

      def recursive_get method, chars
        current_length = 0
        current_key = current_key chars.slice!(0)

        begin
          current_length += 1

          if current_key && (current_key.length == current_length || chars.empty?)
            return children_tree[current_key.to_sym].send method, chars
          end
        end while current_key && current_key[current_length] == chars.slice!(0)
      end

      def current_key letter
        current_key = nil

        children_tree.keys.each do |key|
          key_string = key.to_s
          if key_string.start_with? letter
            current_key = key_string
            break
          end
        end

        current_key
      end
    end
  end
end
