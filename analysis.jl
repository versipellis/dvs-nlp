using CSV
using WordTokenizers
using TextAnalysis

fileloc = pwd() * "/data/subset.csv"
df = CSV.read(fileloc)

tokenize(df[1,3])

function processfile(filename)
    hist = Dict()
    for line in eachline(filename)
        processline(line, hist)
    end
    hist
end;

function processline(line, hist)
    line = replace(line, '-' => ' ')
    for word in split(line)
        word = string(filter(isletter, [word...])...)
        word = lowercase(word)
        hist[word] = get!(hist, word, 0) + 1
    end
end;
