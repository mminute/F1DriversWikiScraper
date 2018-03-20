def identify_odd_chars(str)
    chars = str.split(//)
    odd_chars = []
    chars.each { |char|
        if !char.match(/[a-zA-Z\-]/)
            odd_chars.push(char)
        end
    }

    odd_chars
end