module ChemicalOfTheDay

using Twitter, Downloads, Random, JSON3, Dates, HTTP

const PC_ROOT = "https://pubchem.ncbi.nlm.nih.gov"
const PUG_URL = joinpath(PC_ROOT, "rest/pug")
const PUG_VIEW_URL = joinpath(PC_ROOT, "rest/pug_view")
DATADIR = joinpath(@__DIR__, "../data/")
data(s) = joinpath(DATADIR, s)

function get_json_and_view(input_url; verbose=false)
    verbose && @info input_url
    res = HTTP.get(input_url)
    if res.status == 200
        j = JSON3.read(String(res.body))
        cid = j.PC_Compounds[1].id.id.cid
        input_url2 = "$(PUG_VIEW_URL)/data/compound/$(cid)/JSON"
        j2 = JSON3.read(String(HTTP.get(input_url2).body))
        return j, j2
    else
        error("Cannot Find CID of the species $cname.")
    end
end

function get_json_and_view_from_cid(cid; kwargs...)
    cid = HTTP.escapeuri(cid)
    input_url = "$(PUG_URL)/compound/cid/$(cid)/record/JSON/"#?record_type=3d" # FIX
    get_json_and_view(input_url; kwargs...)
end

function get_molecular_formula_from_jview(jv)
    for sec in jv.Section
        if sec.TOCHeading == "Names and Identifiers"
            for sec2 in sec.Section
                if sec2.TOCHeading == "Molecular Formula"
                    return sec2.Information[1].Value.StringWithMarkup[1].String
                end
            end
        end
    end
    error("not found")
end

function get_description(jview)
    secs = get_sections(jview)
    names_ids = get_names_ids_secs(secs)
    try
        rec_desc = find_toc(names_ids.Section)
        rec_desc.Information[1].Value.StringWithMarkup[1].String
    catch e
        @warn "no description found"
        return ""
    end

end
function date_value(id_secs; kw)
    create_sec = find_toc(id_secs; kw)
    only(create_sec.Information[1].Value.DateISO8601)
end

function get_create_modify_dates(jv; kw)
    secs = get_sections(jv)
    names_ids = get_names_ids_secs(secs)
    try
        date_value(names_ids.Section; kw)
    catch e
        @warn "no dates found"
        missing
    end
end

get_sections(jview) = jview.Record.Section
get_names_ids_secs(secs) = secs[only(findall(x -> x.TOCHeading == "Names and Identifiers", secs))]
find_toc(secs; kw="Record Description") = secs[only(findall(x -> x.TOCHeading == kw, secs))]

# lol
find_toc(s, x) = find_toc(s; kw=x)

get_val(x) = x.Information[1].Value

"if the status section is missing, then i assume the chemical is live"
function is_chem_live(jv)
    try
        n = find_toc(get_sections(jv), "Names and Identifiers")
        st = find_toc(n.Section, "Status")
        x = get_val(st).StringWithMarkup[1].String
        x == "Non-live" ? false : true
    catch e
        true
    end
end

function build_status(id::Integer)
    chem = get_json_and_view_from_cid(id)
    build_status(chem)
end

function build_status(chem)
    chema, jv = chem
    cid = chema.PC_Compounds[1].id.id.cid
    description = ChemicalOfTheDay.get_description(chem[2])
    name = jv.Record.RecordTitle
    formula = get_molecular_formula_from_jview(jv.Record)


    create_date = ChemicalOfTheDay.get_create_modify_dates(jv; kw="Create Date")
    modify_date = ChemicalOfTheDay.get_create_modify_dates(jv; kw="Modify Date")


    """The chemical of $(today()) is $(name) ($formula)!
    ID: $cid

    $description

    https://pubchem.ncbi.nlm.nih.gov/compound/$(cid)

    created: $(create_date)
    last modified: $(modify_date)
    #chemistry #pubchem #chemicaloftheday"""
end


export build_status
end # module ChemicalOfTheDay
