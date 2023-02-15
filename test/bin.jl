using Test, ChemicalOfTheDay, Dates, Twitter, Random
include("../secrets.jl");

IDs = randperm(166000001)
global i = 1
while true
    try
        @info now()
        id = IDs[i]
        auth = twitterauth(api_key, api_key_secret, access_token, token_secret);
        chem = ChemicalOfTheDay.get_json_and_view_from_cid(id) 
        if !ChemicalOfTheDay.is_chem_live(chem[2])
            continue
        end
        status = build_status(chem)
        println(status)
        post_status_update(; status)
        sleep(Day(1))
    catch e

    end
    global i += 1
end
