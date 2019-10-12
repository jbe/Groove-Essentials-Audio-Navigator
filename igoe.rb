require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem "json"
  gem "haml"
  gem "tilt"
  gem "sass"
end


NAMES = {
  1  => "Rock: 8th note rock",
  2  => "Rock: 4 on the floor",
  3  => "Rock: Country / motown style",
  4  => "Rock",
  5  => "Rock",
  6  => "16th note rock",
  7  => "16th note rock: Syncopated",
  8  => "16th note rock: Syncopated 2",
  9  => "Half-time",
  10 => "Half-time: with bell",
  11 => "Funk: syncopation, rimshots",
  12 => "Funk: Accented hat and ghosts",
  13 => "Funk: Stutter (snare on two one sixteenth earlier)",
  14 => "R&B: hip-hop machine",
  15 => "R&B: alternating ride and chick, slightly swung",
  16 => "R&B: \"The Push \" - Heavy accent",
  17 => "R&B: Half-time shuffle",
  18 => "Jazz",
  19 => "Jazz",
  20 => "Jazz",
  21 => "Jazz",
  22 => "Jazz",
  23 => "Jazz",
  24 => "Jazz",
  25 => "Jazz",
  26 => "Jazz",
  27 => "World: Disco",
  28 => "World: Classic Two-Beat",
  29 => "World: New Orleans 2nd line (swing)",
  30 => "World: Reggae (one-drop)",
  31 => "World: Calypso",
  32 => "World: Soca",
  33 => "World: Bossa-nova",
  34 => "World: Samba slow/medium",
  35 => "World: Samba fast",
  36 => "World: Baião Samba",
  37 => "World: Batacuda",
  38 => "World: Merengue",
  39 => "World: Cha cha chá"
}


def parse_ge1
  book_path = "./Groove Essentials 1 Audio/"

  grooves = {}
  extras = []

  Dir[book_path + "groove/*.mp3"].each do |path|

    basename = File.basename(path)

    _, number, speed, variation = basename.match(/^groove(\d+)(SLOW|MEDIUM|FAST|)_(\w+)/).to_a

    number = number.to_i
    speed = if speed && speed.length > 0 then speed.downcase else "normal" end

    grooves[number] ||= {
      "number" => number
    }
    grooves[number]["grooves"] ||= {}
    grooves[number]["grooves"][[variation, speed].compact.join(" ")] = {
      "number" => number,
      "variation" => variation,
      "speed" => speed,
      "path" => path
    }
  end

  Dir[book_path + "chart/*.mp3"].each do |path|

    basename = File.basename(path)

    _, interesting = basename.match(/^ge1-\w{2}_([\w-]+)/).to_a

    _, number, speed = interesting.match(/^(\d+)-_?([\w-]+)/).to_a

    number = number && number.to_i
    speed = if speed && speed.length > 0 then speed.downcase else "normal" end
    name = nil

    if !["slow", "fast", "normal"].include?(speed)
      name = speed
      speed = "normal"
    end

    if !name && NAMES[number]
      name = NAMES[number]
    end

    if !number
      extras << {
        "path" => path,
        "name" => interesting.gsub(/_|-/, " ")
      }
    else
      grooves[number] ||= {
      "number" => number
      }
      grooves[number]["name"] = name if name
      grooves[number]["charts"] ||= {}
      grooves[number]["charts"][speed] = path
    end
  end

  {
    "grooves": grooves,
    "extras": extras
  }
end

def parse_ge2
  book_path = "./Groove Essentials 2 Audio/"

  grooves = {}
  extras = []

  Dir[book_path + "groove/*.mp3"].each do |path|

    basename = File.basename(path)

    _, number, speed, variation = basename.match(/^groove(\d+)(SLOW|FAST|)_(\w+)/).to_a

    number = number.to_i
    speed = if speed && speed.length > 0 then speed.downcase else "normal" end

    grooves[number] ||= {
      "number" => number
    }
    grooves[number]["grooves"] ||= {}
    grooves[number]["grooves"][[variation, speed].compact.join(" ")] = {
      "number" => number,
      "variation" => variation,
      "speed" => speed,
      "path" => path
    }
  end

  Dir[book_path + "chart/*.mp3"].each do |path|

    basename = File.basename(path)

    _, number, _, name = basename.match(/^\w{2}_(\d*)(-|_)?(.+).mp3/).to_a

    variation = nil

    if ["slow", "FAST", "slowly_with_counting", "FAST_letter_C", "song_with_counting",
        "medium_brushes", "fast_brushes"].include? name
      variation = name
      name = nil
    end

    number = number && number.to_i
    number = nil if number && number == 0

    name && name.gsub!(/_/, " ")
    variation && variation.gsub!(/_/, " ")

    name ||= NAMES[number]

    if !number
      extras << {
        "path" => path,
        "name" => name
      }
    else
      grooves[number] ||= {
        "number" => number
      }
      if name
        grooves[number]["name"] = name
      end
      grooves[number]["charts"] ||= {}
      grooves[number]["charts"][variation || "normal"] = path
    end
  end

  {
    "grooves": grooves,
    "extras": extras
  }
end

data = {
  "ge1": parse_ge1(),
  "ge2": parse_ge2()
}


File.write "./data.json", JSON.pretty_generate(data)

template = Tilt.new('template.haml')
output = template.render(nil, data: data)

File.write "index.html", output