# encoding: utf-8
require 'terminal-table'

module Infoboxer
  module Tree
    class Table < Compound
      def empty?
        false
      end

      def rows
        children.select(&fltr(itself: TableRow))
      end

      def caption
        children.detect(&fltr(itself: TableCaption))
      end

      # FIXME: it can easily be several table heading rows
      def heading_row
        rows.first.children.all?(&call(matches?: TableHeading)) ?
          rows.first : nil
      end

      def body_rows
        rows.first.children.all?(&call(matches?: TableHeading)) ?
          rows[1..-1] :
          rows
      end

      def text
        table = Terminal::Table.new
        if caption
          table.title = caption.text.sub(/\n+\Z/, '')
        end
        
        if heading_row
          table.headings = heading_row.children.map(&:text).
            map(&call(sub: [/\n+\Z/, '']))
        end

        table.rows = body_rows.map{|r|
          r.children.map(&:text).
            map(&call(sub: [/\n+\Z/, '']))
        }
        table.to_s + "\n\n"
      end
    end

    class TableRow < Compound
      alias_method :cells, :children

      def empty?
        false
      end
    end

    class BaseCell < Compound
      def empty?
        false
      end
    end

    class TableCell < BaseCell
    end

    class TableHeading < BaseCell
    end

    class TableCaption < Compound
    end
  end
end