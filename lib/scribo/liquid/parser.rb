# frozen_string_literal: true

# Copyright: 2017 - 2018 - MIT License
# Author: Jordon Bedwell
# Encoding: utf-8

module Liquid
  class Tag
    class Parser
      attr_reader :args
      alias raw_args args

      delegate :each, :key?, :to_h, :each_key, :each_with_object, :each_value, :values_at, :to_enum, :map, :[]=, :[], :merge, :merge!, :deep_merge, :deep_merge!, :select, :with_indifferent_access, to: :@args

      FALSE = "!"
      FLOAT = %r!\A\d+\.\d+\Z!
      QUOTE = %r!("|')([^\1]*)(\1)!
      SPECIAL = %r{(?<!\\)(@|!|:|=)}
      BOOL = %r{\A(?<!\\)(!|@)([\w:]+)\Z}
      UNQUOTED_SPECIAL = %r{(?<!\\)(://)}
      SPECIAL_ESCAPED = %r{\\(@|!|:|=)}
      KEY = %r{\b(?<!\\):}
      INT = %r!^\d+$!
      TRUE = "@"

      def initialize(raw, defaults: {}, sep: "=")
        @sep = sep
        @unescaped_sep = sep
        @rsep = Regexp.escape(sep)
        @escaped_sep_regexp = %r!\\(#{@rsep})!
        @sep_regexp = %r{\b(?<!\\)(#{@rsep})}
        @escaped_sep = "\\#{@sep}"
        @args = defaults
        @raw = raw

        parse
      end

      # Consumes a block and wraps around reusably on arguments.
      # @return [Hash<Symbol,Object>,Array<String>]
      def skippable_loop(skip: [], hash: false)
        @args.each_with_object(hash ? {} : []) do |(k, v), o|
          skip_in_html?(k: k, v: v, skips: skip) ? next : yield([k, v], o)
        end
      end

      # @param [Array<Symbol>] skip keys to skip.
      # Converts the arguments into an HTML attribute string.
      # @return [String]
      def to_html(skip: [])
        skippable_loop(skip: skip, hash: false) do |(k, v), o|
          o << (v == true ? k.to_s : "#{k}=\"#{v}\"")
        end.join(" ")
      end

      # @param [Array<Symbol>] skip keys to skip.
      # @param [true,false] html skip non-html values.
      # Converts arguments into an HTML hash (or to arguments).
      # @return [Hash]
      def to_h(skip: [], html: false)
        return @args unless html

        skippable_loop(skip: skip, hash: true) do |(k, v), o|
          o[k] = v
        end
      end

      private

      # @param [String] k the key
      # @param [Object] v the value
      # @param [Array<Symbol>] skips personal skips.
      # Determines if we should skip in HTML.
      # @return [true,false]
      def skip_in_html?(k:, v:, skips: [])
        k == :argv1 || v.is_a?(Array) || skips.include?(k) \
           || v.is_a?(Hash) || v == false
      end

      # @return [true,nil] a truthy value.
      # @param [Integer] i the current iteration.
      # @param [String] k the keys that will be split.
      # @param [String] v the value.
      def argv1(i:, k:, v:)
        if i.zero? && k.empty? && v !~ BOOL && v !~ @sep_regexp
          @args[:argv1] = unescape(convert(v))
        end
      end

      # @return [Array<String,true|false>]
      # Allows you to flip a value based on condition.
      # @param [String] v the value.
      def flip_kv_bool(v)
        [
          v.gsub(BOOL, "\\2"),
          v.start_with?(TRUE) ? true : false,
        ]
      end

      # @param [Array<Symbol>] keys the keys.
      # Builds a sub-hash or returns parent hash.
      # @return [Hash]
      def build_hash(keys)
        out = @args

        if keys.size > 1
          out = @args[keys[0]] ||= {}
          keys[1...-1].each do |sk|
            out = out[sk] ||= {}
          end
        end

        out
      end

      def unescape(val)
        return unless val

        val.gsub(@escaped_sep_regexp, @unescaped_sep).gsub(
          SPECIAL_ESCAPED, "\\1")
      end

      def parse
        Shellwords.split(@raw).each_with_index do |k, i|
          keys, _, val = k.rpartition(@sep_regexp)
          next if argv1(i: i, k: keys, v: val)

          val = unescape(val)
          keys, val = flip_kv_bool(val) if val =~ BOOL && keys.empty?
          if keys.empty?
            keys = val
            val = nil
          end
          keys = keys.split(KEY).map(&:to_sym)

          set_val(
            v: convert(val),
            hash: build_hash(keys),
            k: keys.last
          )
        end
      end

      def set_val(k:, v:, hash:)
        hash[k] << v if hash[k].is_a?(Array)
        hash[k] = [hash[k]].flatten << v if hash[k] && !hash[k].is_a?(Array)
        hash[k] = v unless hash[k]
      end

      # @return [true,false,Float,Integer]
      # Convert a value to a native value.
      def convert(val)
        return val.to_f if val =~ FLOAT
        return val.to_i if val =~ INT

        val
      end
    end
  end
end
