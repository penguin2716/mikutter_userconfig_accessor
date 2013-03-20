#-*- coding: utf-8 -*-

class ::UserConfig
  def self.configloader_pstore
    @@configloader_pstore
  end
end

Plugin.create :userconfig_accessor do

  settings "UserConfig Accessor" do

    accessibles = `grep -ERo '(color|boolean|input|inputpass|adjustment)\\s*\\(?\\s*["'\\''].+' * | sed 's/^[^:]\\+://g' | grep -Eo ':[a-zA-Z0-9_]+' | sort -u`.split("\n")
    accessibles += `grep -ERo '(color|boolean|input|inputpass|adjustment)\\s*\\(?\\s*["'\\''].+' #{Environment::CONFROOT}/plugin | sed 's/^[^:]\\+://g' | grep -Eo ':[a-zA-Z0-9_]+' | sort -u`.split("\n")
    inaccessibles = []

    db = UserConfig.configloader_pstore
    db.transaction do
      inaccessibles = db.roots.map{|key| key.sub(/^[^:]+:/, '')}.reject{|key| accessibles.include? key}
    end

    settings "String" do
      inaccessibles.each do |key|
        keysym = key[1..-1].to_sym
        c = UserConfig[keysym].class
        if c == String
          if key =~ /password/
            inputpass(key[1..-1], keysym).tooltip(`grep -Rn 'UserConfig\\[#{key}\\]' * #{Environment::CONFROOT}/plugin`)
          else
            input(key[1..-1], keysym).tooltip(`grep -Rn 'UserConfig\\[#{key}\\]' * #{Environment::CONFROOT}/plugin`)
          end
        end
      end
    end

    settings "Boolean" do
      inaccessibles.each do |key|
        keysym = key[1..-1].to_sym
        c = UserConfig[keysym].class
        if c == TrueClass or c == FalseClass
          boolean(key[1..-1].gsub('_', '__'), keysym).tooltip(`grep -Rn 'UserConfig\\[#{key}\\]' * #{Environment::CONFROOT}/plugin`)
        end
      end  
    end

    settings "Fixnum" do
      inaccessibles.each do |key|
        keysym = key[1..-1].to_sym
        c = UserConfig[keysym].class
        if c == Fixnum
          adjustment(key[1..-1], keysym, -100000, 100000).tooltip(`grep -Rn 'UserConfig\\[#{key}\\]' * #{Environment::CONFROOT}/plugin`)
        end
      end  
    end
    
    settings "Color" do
      inaccessibles.each do |key|
        keysym = key[1..-1].to_sym
        array = UserConfig[keysym]
        if array.class == Array
          if array.size == 3
            if array.select{|e| e.class == Fixnum}.size == 3
              if array.select{|e| 0x0000 <= e and e <= 0xffff}.size == 3
                color(key[1..-1], keysym).tooltip(`grep -Rn 'UserConfig\\[#{key}\\]' * #{Environment::CONFROOT}/plugin`)
              end
            end
          end
        end
      end  
    end

  end

end
