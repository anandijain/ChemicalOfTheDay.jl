using Test, ChemicalOfTheDay, Dates, Twitter
# status = build_status(325132)
# println(status)
# post_status_update(; status)

include("../secrets.jl")
auth = twitterauth(api_key, api_key_secret, access_token, token_secret);
IDs = randperm(166000001)
i = 1
while true
    status = build_status(IDs[i])
    println(status)
    post_status_update(; status)
    sleep(Day(1))
    i += 1
end
