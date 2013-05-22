module Utils
  class ItemSet < Array
    def pluck(item)
      if item.length > 0
        self.grep(/^#{item}/i).first
      else
        nil
      end
    end
  end
end

