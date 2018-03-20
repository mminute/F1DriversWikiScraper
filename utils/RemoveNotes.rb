def remove_notes(str)
    str.gsub(/\[\d+\]/, '')
end