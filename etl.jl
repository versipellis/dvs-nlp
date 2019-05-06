#---- LOADING
using JSON
using Plots
#plotlyjs()
pyplot()
using DataFrames
using DataFramesMeta
wdir = pwd()
datadir = wdir * "/data/-introductions/-introductions/"

#---- GET ALL DATA FILES
filelist = String[]
for (root, dirs, files) in walkdir(datadir)
    for file in files
        push!(filelist, joinpath(root,file))
    end
end

#---- GET MESSAGE LENGTHS, PLOT
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
print(length(messagelengths))
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
for i in filelist
    println("\n     LOADING FILE: " * i * "\n")
    parsedfile = JSON.parsefile(i);
    for j in parsedfile
        if (j["type"] == "message" && length(j["text"]) > 50)
            push!(UID, j["user"]),
            push!(TS, j["ts"]),
            push!(Messages, j["text"])
        end
    end
end
df = DataFrame(user = UID, timestamp = TS, message = Messages)

#---- ETL DF
sort!(df, [:user, :timestamp])
show(first(df, 100),true)
dfgrouped = by(df, :user, :message => length)
sort!(dfgrouped, :message_length, rev = true)
