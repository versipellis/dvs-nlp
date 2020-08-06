#---- LOADING
using JSON
using CSV
using Plots
#plotlyjs()
pyplot()
using DataFrames
using DataFramesMeta
using StatsPlots
wdir = pwd()
datadir = wdir * "/data/-introductions/-introductions/"

#---- GET ALL DATA FILES
filelist = String[]
for (root, dirs, files) in walkdir(datadir)
    for file in files
        push!(filelist, joinpath(root,file))
    end
end

#---- GET MESSAGE LENGTHS
messagelengths = Int32[]
for i in filelist
    println("\n     LOADING FILE: " * i * "\n")
    parsedfile = JSON.parsefile(i);
    for j in parsedfile
        if (j["type"] == "message")
            push!(messagelengths, length(j["text"]))
        end
    end
end

#---- PLOT
#print(length(messagelengths))
histogram(messagelengths,
            bins = range(
                        minimum(messagelengths),
                        stop=maximum(messagelengths),
                        step=25),
            title = "Message Lengths Histogram",
            xlabel = "Binning by 25",
            #xtickfontrotation = 45,
            xtickfontsize = 5,
            xticks = minimum(messagelengths):100:maximum(messagelengths),
            grid = (:x,
                    :cadetblue,
                    :dot,
                    0.5,
                    1)
        )

#---- GET ACTUAL MESSAGES + UID AND TIMESTAMP
UID = String[]
TS = String[]
Messages = String[]
MessageLength = Int32[]
for i in filelist
    println("\n     LOADING FILE: " * i * "\n")
    parsedfile = JSON.parsefile(i);
    for j in parsedfile
        if (j["type"] == "message" && length(j["text"]) > 75)
            push!(UID, j["user"]),
            push!(TS, j["ts"]),
            push!(MessageLength, length(j["text"])),
            push!(Messages, j["text"])
        end
    end
end
TS = map(x->parse(Float64,x),TS)
df = DataFrame(user = UID, timestamp = TS, length = MessageLength, message = Messages)

#---- ETL DF
sort!(df, [:user, :timestamp, :length])
show(first(df, 100),true)
dfgrouped = by(df, :user, :message => length)
sort!(dfgrouped, :message_length, rev = true)

#---- PLOT
@df dfgrouped scatter(:user,
                        :message_length,
                        markersize = 2,
                        markercolor = :black,
                        markeralpha = 0.5,
                        markerstrokewidth = 0,
                        title = "Per user # Messages > len 50")

#---- SUBSET
#earliest_per_user = by(df, :user, timestamp = :timestamp => minimum)
#test = join(earliest_per_user, df, on=[:user, :timestamp])
dfsubset = @linq df |>
        groupby(:user) |>
        transform(ismin = (:timestamp .== minimum(:timestamp))) |>
        where(:ismin .== true) |>
        select(:timestamp, :length, :message)

show(first(dfsubset, 100),true)
exportloc = pwd() * "/data/subset.csv"
CSV.write(exportloc, dfsubset)
